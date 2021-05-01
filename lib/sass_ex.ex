defmodule SassEx do
  @moduledoc """
  Documentation for `SassEx`.
  """

  use Application

  alias SassEx.SassProcessor

  def compile(content, importers \\ nil),
    do: SassProcessor.compile(SassProcessor, content, importers)

  def start(_type, _args) do
    children = [
      # Define workers and child supervisors to be supervised
      {SassEx.SassProcessor, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: SassEx)
  end
end
