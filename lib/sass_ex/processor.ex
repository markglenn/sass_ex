defmodule SassEx.Processor do
  @moduledoc """
  Sass processor. Manages the communication between the Dart Sass Embedded
  processor and Elixir.
  """

  use GenServer
  require Logger

  @macos_command "../../vendor/sass_embedded/macos/dart-sass-embedded"
  @linux64_command "../../vendor/sass_embedded/linux64/dart-sass-embedded"
  @win64_command "../../vendor/sass_embedded/win64/dart-sass-embedded.bat"

  alias Sass.EmbeddedProtocol.{InboundMessage, OutboundMessage}
  alias Sass.EmbeddedProtocol.InboundMessage.CompileRequest.Importer

  alias SassEx.Request
  alias SassEx.RPC.Message

  @doc false
  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]}
    }
  end

  @type importer_t :: Module | Struct
  @type state_t :: %{
          port: port | nil,
          buffer: binary,
          requests: %{optional(pos_integer) => Request.t()},
          last_request_id: non_neg_integer()
        }

  @type compile_opts :: [
          importers: [importer_t()] | [] | nil,
          style: :expanded | :compressed,
          source_map: boolean,
          syntax: :css | :sass | :scss
        ]

  # GenServer API
  @spec start_link(any, GenServer.options()) :: GenServer.on_start()
  @doc false
  def start_link(args \\ [], opts \\ []) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, args, opts)
  end

  @spec init(any) :: {:ok, state_t}
  @doc false
  def init(_opts) do
    relative_command =
      case :os.type() do
        {:unix, :darwin} -> @macos_command
        {:unix, _} -> @linux64_command
        {:win32, _} -> @win64_command
      end

    command =
      __ENV__.file
      |> Path.dirname()
      |> Path.join(relative_command)
      |> Path.expand()

    port = Port.open({:spawn_executable, command}, [:binary, :exit_status])

    {:ok, %{port: port, buffer: <<>>, requests: %{}, last_request_id: 0}}
  end

  @spec compile(GenServer.server(), String.t(), compile_opts) :: term
  @doc false
  def compile(pid, body, opts),
    do: GenServer.call(pid, {:compile, body, opts}, 2000)

  def handle_call({:compile, body, opts}, from, state) do
    alias InboundMessage.CompileRequest.StringInput

    style =
      case Keyword.get(opts, :style, :expanded) do
        :expanded -> :EXPANDED
        :compressed -> :COMPRESSED
      end

    importers = Keyword.get(opts, :importers)
    source_map = Keyword.get(opts, :source_map, false)

    syntax =
      case Keyword.get(opts, :syntax) do
        :css -> :CSS
        :sass -> :INDENTED
        :scss -> :SCSS
        _ -> nil
      end

    # Use the default importer or the first given
    relative_importer =
      case importers do
        nil -> nil
        [path | _] when is_binary(path) -> Importer.new(%{importer: {:path, path}})
        _ -> Importer.new(%{importer: {:importer_id, 0}})
      end

    input = StringInput.new(%{source: body, importer: relative_importer, syntax: syntax})

    state = Map.put(state, :last_request_id, state.last_request_id + 1)

    request = %Request{
      id: state.last_request_id,
      pid: from,
      importers: importers
    }

    message =
      InboundMessage.CompileRequest.new(%{
        input: {:string, input},
        id: request.id,
        source_map: source_map,
        style: style,
        importers: importers(importers)
      })

    send_message(state, :compile_request, message)

    # This is an asynchronouse call, so don't yet reply to the caller
    {:noreply, %{state | requests: Map.put(state.requests, request.id, request)}}
  end

  # This callback handles data incoming from the command's STDOUT
  def handle_info({_port, {:data, data}}, state) do
    %{state | buffer: state.buffer <> data}
    |> decode_message()
  end

  # This callback tells us when the process exits
  def handle_info({_port, {:exit_status, status}}, state) do
    Logger.info("External exit: :exit_status: #{status}")

    # Our process is stopped, so we should kill this GenServer
    {:stop, :normal, state}
  end

  # no-op catch-all callback for unhandled messages
  def handle_info(msg, state) do
    Logger.warn(fn -> "Invalid message received: #{inspect(msg)}" end)
    {:noreply, state}
  end

  @spec decode_message(state_t) :: {:noreply, state_t}
  defp decode_message(state) do
    case Message.decode(state.buffer) do
      :incomplete ->
        {:noreply, state}

      {:ok, %{message: {_, message}}, rest} ->
        state
        |> handle_message(message)
        |> Map.put(:buffer, rest)
        |> decode_message()
    end
  end

  @spec terminate(term, state_t) :: :ok
  def terminate(_reason, %{port: port}) do
    Port.close(port)
    :ok
  end

  defp send_message(%{port: port}, type, message),
    do: Port.command(port, Message.encode(type, message))

  defp handle_message(
         state,
         %OutboundMessage.CompileResponse{id: id, result: {_, message}}
       ) do
    case Map.get(state.requests, id) do
      %Request{pid: pid} ->
        GenServer.reply(pid, message)

        %{state | requests: Map.delete(state.requests, id)}

      _ ->
        state
    end
  end

  defp handle_message(state, %OutboundMessage.CanonicalizeRequest{
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
        r -> r
      end

    message = InboundMessage.CanonicalizeResponse.new(%{id: id, result: result})

    send_message(state, :canonicalize_response, message)

    state
  end

  defp handle_message(state, %OutboundMessage.ImportRequest{} = request) do
    alias Sass.EmbeddedProtocol.InboundMessage.ImportResponse
    alias Sass.EmbeddedProtocol.InboundMessage.ImportResponse.ImportSuccess

    result =
      state
      |> importer_for(request.compilation_id, request.importer_id)
      |> load_contents(request.url)
      |> case do
        {:ok, contents} ->
          {:success, ImportSuccess.new(%{contents: contents})}

        {:error, error} ->
          {:error, error}
      end

    message = ImportResponse.new(%{result: result, id: request.id})
    send_message(state, :import_response, message)
    state
  end

  defp handle_message(state, response) do
    Logger.warn(fn -> "Unknown message received from SASS compiler: #{inspect(response)}" end)

    state
  end

  defp canonicalize_url(nil, _), do: {:error, "Invalid importer"}
  defp canonicalize_url(%module{} = importer, url), do: module.canonicalize(importer, url)
  defp canonicalize_url(importer, url), do: importer.canonicalize(nil, url)

  defp load_contents(nil, _), do: {:error, "Invalid importer"}
  defp load_contents(%module{} = importer, url), do: module.load(importer, url)
  defp load_contents(module, url), do: module.load(nil, url)

  @spec importers([importer_t()] | nil) :: [
          InboundMessage.CompileRequest.Importer.t()
        ]
  defp importers(nil), do: []

  defp importers(importers) do
    importers
    |> Enum.with_index()
    |> Enum.map(&Importer.new(%{importer: {:importer_id, elem(&1, 1)}}))
  end

  defp importer_for(%{requests: requests}, compilation_id, importer_id) do
    requests
    |> Map.get(compilation_id, %{})
    |> Map.get(:importers, [])
    |> Enum.at(importer_id)
  end
end
