defmodule SassEx.SassProcessor do
  use GenServer
  require Logger

  @command "./vendor/sass_embedded/dart-sass-embedded"

  alias Sass.EmbeddedProtocol.InboundMessage
  alias Sass.EmbeddedProtocol.OutboundMessage

  alias SassEx.Processor.Packet
  alias SassEx.Processor.OpenRequest

  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]}
    }
  end

  @type state_t :: %{
          port: port,
          buffer: binary,
          requests: %{optional(pos_integer) => OpenRequest.t()}
        }

  # GenServer API
  @spec start_link(any, GenServer.options()) :: GenServer.on_start()
  def start_link(args \\ [], opts \\ []) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, args, opts)
  end

  @spec init(any) :: {:ok, state_t}
  def init(_opts) do
    port = Port.open({:spawn, @command}, [:binary, :exit_status])

    {:ok, %{port: port, buffer: <<>>, requests: %{}}}
  end

  @spec compile(GenServer.server(), String.t(), [OpenRequest.importer_t()]) :: term
  def compile(pid, body, importers \\ []), do: GenServer.call(pid, {:compile, body, importers})

  def handle_call({:compile, body, importers}, from, state) do
    input = InboundMessage.CompileRequest.StringInput.new(%{source: body})
    request = %OpenRequest{id: unique_id(state), pid: from, importers: importers}

    message =
      InboundMessage.CompileRequest.new(%{
        input: {:string, input},
        id: request.id,
        source_map: true,
        style: :EXPANDED,
        importers: importers(importers)
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

    # Our process is stopped, so we should kill this GenServer
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
    Port.command(port, Packet.encode(type, message))
  end

  defp handle_packet(
         state,
         %OutboundMessage.CompileResponse{id: id, result: {_, packet}}
       ) do
    case Map.get(state.requests, id) do
      %OpenRequest{pid: pid} ->
        GenServer.reply(pid, packet)
        %{state | requests: Map.delete(state.requests, id)}

      _ ->
        state
    end
  end

  defp handle_packet(state, %OutboundMessage.CanonicalizeRequest{
         id: id,
         importer_id: importer_id,
         compilation_id: compilation_id,
         url: url
       }) do
    result =
      state
      |> importer_for(compilation_id, importer_id)
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
    alias Sass.EmbeddedProtocol.InboundMessage.ImportResponse

    result =
      state
      |> importer_for(request.compilation_id, request.importer_id)
      |> load_contents(request.url)
      |> case do
        {:ok, contents} ->
          {:success, ImportResponse.ImportSuccess.new(%{contents: contents})}

        {:error, error} ->
          {:error, error}
      end

    message = ImportResponse.new(%{result: result, id: request.id})
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

  defp unique_id(%{requests: requests} = state) do
    id = rem(System.unique_integer([:positive]), 4_294_967_295)

    if Map.has_key?(requests, id) do
      unique_id(state)
    else
      id
    end
  end

  @spec importers(any) :: [InboundMessage.CompileRequest.Importer.t()]
  defp importers([]), do: []

  defp importers(importers) do
    alias InboundMessage.CompileRequest.Importer

    importer_count = length(importers)

    0..(importer_count - 1)
    |> Enum.map(&Importer.new(%{importer: {:importer_id, &1}}))
  end

  defp importer_for(%{requests: requests}, compilation_id, importer_id) do
    requests
    |> Map.get(compilation_id, %{})
    |> Map.get(:importers, [])
    |> Enum.at(importer_id)
  end
end
