defmodule SassEx do
  @moduledoc ~S"""
  Sass/SCSS compiler for elixir that leverages the embedded sass protocol to
  interoperate with Dart Sass.

  ## Basic Usage

      iex> SassEx.compile(".example { color: red; }")
      {:ok, %SassEx.Response{css: ".example {\n  color: red;\n}", source_map: ""}}
  """

  use Application

  alias SassEx.Processor

  alias Sass.EmbeddedProtocol.OutboundMessage.CompileResponse.{
    CompileFailure,
    CompileSuccess
  }

  @spec compile(binary, Processor.compile_opts()) ::
          {:ok, SassEx.Response.t()} | {:error, String.t(), CompileFailure.t()}
  @doc ~S"""
  Compile the `content` string.

  ## Examples
      SassEx.compile(content, source_map: true, style: :expanded)

  ## Options
    * `:style` - Either `:expanded` or `:compressed`. Defaults to `:expanded`
    * `:source_map` - True if the compilation should include a source map. Defaults to `false`
    * `:syntax` - Either `:css` for raw CSS, `:scss` for SCSS format, or `:sass` for SASS/embedded format. Defaults to `:scss`
    * `:importers` - List of custom importers.  See `SassEx.Importer` for more information
  """
  def compile(content, opts \\ []) do
    Processor
    |> Processor.compile(content, opts)
    |> from_compile_response()
  end

  @doc false
  def start(_type, _args) do
    children = [
      # Define workers and child supervisors to be supervised
      {SassEx.Processor, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: SassEx)
  end

  @doc false
  defp from_compile_response(%CompileSuccess{css: css, source_map: source_map}) do
    {:ok,
     %SassEx.Response{
       css: css,
       source_map: source_map
     }}
  end

  defp from_compile_response(%CompileFailure{message: message} = failure) do
    {:error, message, failure}
  end
end
