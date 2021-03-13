defmodule ScssEx.SassProcessor do
  use GenServer
  require Logger

  @command "./vendor/sass_embedded/dart-sass-embedded"

  alias Sass.EmbeddedProtocol.InboundMessage

  alias Sass.EmbeddedProtocol.InboundMessage.{
    CanonicalizeResponse,
    CompileRequest,
    ImportResponse
  }

  alias Sass.EmbeddedProtocol.InboundMessage.CompileRequest.{
    Importer,
    StringInput
  }

  alias Sass.EmbeddedProtocol.InboundMessage.ImportResponse.ImportSuccess

  alias Sass.EmbeddedProtocol.OutboundMessage

  alias Sass.EmbeddedProtocol.OutboundMessage.{
    CanonicalizeRequest,
    CompileResponse,
    ImportRequest
  }

  alias ScssEx.Packet
  alias ScssEx.Request

  @type state_t :: %{
          port: port,
          buffer: binary,
          requests: %{pos_integer: Request.t()} | %{}
        }

  # GenServer API
  @spec start_link(any, GenServer.options()) :: GenServer.on_start()
  def start_link(args \\ [], opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  @spec init(any) :: {:ok, state_t}
  def init(_args \\ []) do
    port = Port.open({:spawn, @command}, [:binary, :exit_status])
    {:ok, %{port: port, buffer: <<>>, requests: %{}}}
  end

  @spec compile(GenServer.server(), String.t()) :: term
  def compile(pid, body) do
    GenServer.call(pid, {:compile, body})
  end

  def handle_call({:compile, body}, from, state) do
    input = StringInput.new(%{source: body})
    request = %Request{id: System.unique_integer([:positive]), pid: from}

    message =
      CompileRequest.new(%{
        input: {:string, input},
        id: request.id,
        source_map: true,
        style: :EXPANDED,
        importers: [
          Importer.new(%{importer: {:importer_id, 1}})
        ]
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

      %Packet{body: body, rest: rest} ->
        %{message: {_, message}} = OutboundMessage.decode(body)

        state = handle_packet(state, message)
        {:noreply, %{state | buffer: rest}}
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

    l = byte_size(msg)
    Port.command(port, <<l>> <> msg)
  end

  defp handle_packet(
         state,
         %CompileResponse{id: id, result: {:success, packet}}
       ) do
    case Map.get(state.requests, id) do
      nil ->
        state

      %Request{pid: pid} ->
        GenServer.reply(pid, packet)
        Map.delete(state.requests, id)
    end
  end

  defp handle_packet(state, %CompileResponse{id: id, result: {:failure, packet}}) do
    case Map.get(state.requests, id) do
      nil ->
        state

      %Request{pid: pid} ->
        GenServer.reply(pid, packet)
        Map.delete(state.requests, id)
    end
  end

  defp handle_packet(state, %CanonicalizeRequest{} = request) do
    message =
      %{
        id: request.id,
        result: {:url, "scssex://" <> request.url}
      }
      |> CanonicalizeResponse.new()

    send_message(state, :canonicalizeResponse, message)

    state
  end

  defp handle_packet(state, %ImportRequest{} = request) do
    success = ImportSuccess.new(%{contents: "body { color: red; }"})

    message = ImportResponse.new(%{result: {:success, success}, id: request.id})
    send_message(state, :importResponse, message)
    state
  end

  defp handle_packet(state, response) do
    Logger.info("Unknown message received from SASS compiler: #{inspect(response)}")

    state
  end
end
