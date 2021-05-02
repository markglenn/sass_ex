defmodule SassExTest do
  use ExUnit.Case
  doctest SassEx

  defmodule TestImporter do
    @behaviour SassEx.Importer

    def canonicalize(_, path), do: {:ok, "test://#{path}"}
    def load(_, "test://" <> path), do: {:ok, ".test { content: \"#{path}\"; }"}
  end

  defmodule FailingImporter do
    @behaviour SassEx.Importer

    def canonicalize(_, _path), do: nil
    def load(_, _path), do: {:error, "Not supported"}
  end

  alias Sass.EmbeddedProtocol.OutboundMessage.CompileResponse.{
    CompileFailure,
    CompileSuccess
  }

  test "handle simple CSS" do
    assert %CompileSuccess{} = SassEx.compile("div { color: blue; }")
  end

  test "handles external import" do
    assert %CompileSuccess{} = SassEx.compile("@import 'test/fixtures/colors'")

    assert %CompileFailure{} = SassEx.compile("@import 'test/fixtures/invalid'")
  end

  test "handle custom importer" do
    assert %CompileSuccess{css: css} = SassEx.compile("@import 'example'", [TestImporter])
    assert String.contains?(css, "\"example\"")
    assert String.contains?(css, "content:")
  end

  test "handles multiple importers" do
    assert %CompileSuccess{css: css} =
             SassEx.compile("@import 'example'", [FailingImporter, TestImporter])

    assert String.contains?(css, "\"example\"")
    assert String.contains?(css, "content:")
  end

  test "heavy load" do
    tasks =
      for _i <- 1..1000 do
        Task.async(fn ->
          assert %CompileSuccess{} = SassEx.compile("div { color: blue; }")
        end)
      end

    Task.yield_many(tasks)
  end
end
