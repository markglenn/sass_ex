defmodule ScssEx.SassProcessor do
  use GenServer
  require Logger

  @command "./vendor/sass_embedded/dart-sass-embedded"

  alias Sass.EmbeddedProtocol.InboundMessage
  alias Sass.EmbeddedProtocol.OutboundMessage

  alias ScssEx.Processor.Packet
  alias ScssEx.Processor.OpenRequest

  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]}
    }
  end

  @type state_t :: %{
          port: port,
          buffer: binary,
          requests: %{optional(pos_integer) => Request.t()},
          importers: %{optional(pos_integer) => Module | Struct}
        }

  # GenServer API
  @spec start_link(any, GenServer.options()) :: GenServer.on_start()
  def start_link(args \\ [], opts \\ []) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, args, opts)
  end

  @spec init(any) :: {:ok, state_t}
  def init(opts) do
    importers =
      Keyword.get(opts, :importers, [])
      |> Enum.with_index(1)
      |> Map.new(&{elem(&1, 1), elem(&1, 0)})

    port = Port.open({:spawn, @command}, [:binary, :exit_status])

    state = %{
      port: port,
      buffer: <<>>,
      requests: %{},
      importers: importers
    }

    {:ok, state}
  end

  @spec compile(GenServer.server(), String.t()) :: term
  def compile(pid, body), do: GenServer.call(pid, {:compile, body})

  def handle_call({:compile, body}, from, state) do
    input = InboundMessage.CompileRequest.StringInput.new(%{source: body})
    request = %OpenRequest{id: unique_id(), pid: from}

    message =
      InboundMessage.CompileRequest.new(%{
        input: {:string, input},
        id: request.id,
        source_map: true,
        style: :EXPANDED,
        importers: importers(state)
      })

    send_message(state, :compileRequest, message)

    {:noreply, %{state | requests: Map.put(state.requests, request.id, request)}}
  end

  # This callback handles data incoming from the command's STDOUT
  def handle_info({_pid, {:data, data}}, state) do
    buffer = state.buffer <> data

    case Packet.parse(buffer) do
      :incomplete ->
        {:noreply, %{state | buffer: buffer}}

      {:ok, body, rest} ->
        %{message: {_, message}} = OutboundMessage.decode(body)

        state =
          state
          |> handle_packet(message)
          |> Map.put(:buffer, rest)

        {:noreply, state}
    end
  end

  # This callback tells us when the process exits
  def handle_info({_port, {:exit_status, status}}, state) do
    Logger.info("External exit: :exit_status: #{status}")

    # Our process as stopped, so we should kill this GenServer
    {:stop, :normal, state}
  end

  # no-op catch-all callback for unhandled messages
  def handle_info(msg, state) do
    Logger.info("Invalid message received: #{inspect(msg)}")
    {:noreply, state}
  end

  def terminate(_reason, %{port: port}) do
    Port.close(port)
    :ok
  end

  defp send_message(%{port: port}, type, message) do
    msg =
      %{message: {type, message}}
      |> InboundMessage.new()
      |> InboundMessage.encode()

    Port.command(port, <<byte_size(msg)>> <> msg)
  end

  defp handle_packet(
         state,
         %OutboundMessage.CompileResponse{id: id, result: {:success, packet}}
       ) do
    case Map.get(state.requests, id) do
      nil ->
        state

      %OpenRequest{pid: pid} ->
        GenServer.reply(pid, packet)
        Map.delete(state.requests, id)
    end
  end

  defp handle_packet(state, %OutboundMessage.CompileResponse{id: id, result: {:failure, packet}}) do
    case Map.get(state.requests, id) do
      nil ->
        state

      %OpenRequest{pid: pid} ->
        GenServer.reply(pid, packet)
        Map.delete(state.requests, id)
    end
  end

  defp handle_packet(state, %OutboundMessage.CanonicalizeRequest{
         id: id,
         importer_id: importer_id,
         url: url
       }) do
    result =
      state.importers
      |> Map.get(importer_id)
      |> canonicalize_url(url)
      |> case do
        {:ok, url} -> {:url, url}
        {:error, _} = r -> r
      end

    message = InboundMessage.CanonicalizeResponse.new(%{id: id, result: result})

    send_message(state, :canonicalizeResponse, message)

    state
  end

  defp handle_packet(state, %OutboundMessage.ImportRequest{} = request) do
    result =
      state.importers
      |> Map.get(request.importer_id)
      |> load_contents(request.url)
      |> case do
        {:ok, contents} ->
          {:success, InboundMessage.ImportResponse.ImportSuccess.new(%{contents: contents})}

        {:error, error} ->
          {:error, error}
      end

    message = InboundMessage.ImportResponse.new(%{result: result, id: request.id})
    send_message(state, :importResponse, message)
    state
  end

  defp handle_packet(state, response) do
    Logger.info("Unknown message received from SASS compiler: #{inspect(response)}")

    state
  end

  defp canonicalize_url(nil, _), do: {:error, "Invalid importer"}
  defp canonicalize_url(%module{} = importer, url), do: module.canonicalize(importer, url)
  defp canonicalize_url(importer, url), do: importer.canonicalize(nil, url)

  defp load_contents(nil, _), do: {:error, "Invalid importer"}
  defp load_contents(%module{} = importer, url), do: module.load(importer, url)
  defp load_contents(module, url), do: module.load(nil, url)

  defp unique_id, do: System.unique_integer([:positive])

  @spec importers(state_t) :: [InboundMessage.CompileRequest.Importer.t()]
  defp importers(%{importers: importers}) do
    importers
    |> Enum.map(fn {k, _} ->
      InboundMessage.CompileRequest.Importer.new(%{importer: {:importer_id, k}})
    end)
  end
end
