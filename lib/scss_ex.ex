defmodule ScssEx do
  @moduledoc """
  Documentation for `ScssEx`.
  """

  def main(_args) do
    {:ok, pid} = ScssEx.SassProcessor.start_link()

    response =
      ScssEx.SassProcessor.compile(
        pid,
        "@import 'testing'; .hello { color: red; }"
      )

    response
    |> IO.inspect()
  end
end
