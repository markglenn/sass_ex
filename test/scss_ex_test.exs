defmodule SassExTest do
  use ExUnit.Case
  doctest SassEx

  alias Sass.EmbeddedProtocol.OutboundMessage.CompileResponse.CompileSuccess

  test "handle simple CSS" do
    assert %CompileSuccess{} = SassEx.compile("div { color: blue; }")
  end

  test "handles external import" do
    SassEx.compile("@import 'test/fixtures/colors'")
    |> IO.inspect()

    # assert %CompileSuccess{} =
    #          SassEx.compile("@import 'file:///test/fixtures/colors'", [
    #            SassEx.Importer.FileImporter
    #          ])
  end
end
