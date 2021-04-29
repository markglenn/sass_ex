defmodule ScssEx do
  @moduledoc """
  Documentation for `ScssEx`.
  """

  use Application

  alias ScssEx.SassProcessor

  def compile(content \\ ".hello { color: red; }") do
    SassProcessor.compile(SassProcessor, content)
  end

  def start(_type, _args) do
    children = [
      # Define workers and child supervisors to be supervised
      {ScssEx.SassProcessor, importers: [ScssEx.Importer.FileImporter]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ScssEx)
  end
end
