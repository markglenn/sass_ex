defmodule SassEx do
  @moduledoc """
  Documentation for `SassEx`.
  """

  use Application

  alias SassEx.SassProcessor

  def compile(content \\ ".hello { color: red; }", importers \\ []),
    do: SassProcessor.compile(SassProcessor, content, importers)

  def start(_type, _args) do
    children = [
      # Define workers and child supervisors to be supervised
      {SassEx.SassProcessor, importers: [SassEx.Importer.FileImporter]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: SassEx)
  end
end
