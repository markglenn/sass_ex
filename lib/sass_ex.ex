defmodule SassEx do
  @moduledoc """
  Documentation for `SassEx`.
  """

  use Application

  alias SassEx.Processor

  def compile(content, importers \\ nil),
    do: Processor.compile(Processor, content, importers)

  def start(_type, _args) do
    children = [
      # Define workers and child supervisors to be supervised
      {SassEx.Processor, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: SassEx)
  end
end
