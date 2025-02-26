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

  @css "div { color: blue; }"
  @scss "div { p { color: blue; } }"
  @sass """
  div
    p
      color: blue
  """

  test "handle simple CSS" do
    assert {:ok, _} = SassEx.compile(@css, syntax: :css)
    assert {:error, _, _} = SassEx.compile(@sass, syntax: :css)
  end

  test "handles simple SCSS" do
    assert {:ok, %SassEx.Response{css: "div p {\n  color: blue;\n}", source_map: ""}} =
             SassEx.compile(@scss, syntax: :scss)
  end

  test "handles SASS/indented format" do
    assert {:ok, %SassEx.Response{css: "div p {\n  color: blue;\n}", source_map: ""}} =
             SassEx.compile(@sass, syntax: :sass)
  end

  test "handles external import" do
    assert {:ok, %SassEx.Response{css: ".red {\n  color: red;\n}", source_map: ""}} =
             SassEx.compile("@import 'test/fixtures/colors'", importers: ["."])

    assert {:error, _, _} = SassEx.compile("@import 'test/fixtures/invalid'", importers: ["."])
  end

  test "handle custom importer" do
    assert {:ok, %{css: css}} = SassEx.compile("@import 'example'", importers: [TestImporter])

    assert String.contains?(css, "\"example\"")
    assert String.contains?(css, "content:")
  end

  test "handles multiple importers" do
    assert {:ok, %{css: css}} =
             SassEx.compile("@import 'example'", importers: [FailingImporter, TestImporter])

    assert String.contains?(css, "\"example\"")
    assert String.contains?(css, "content:")
  end

  test "heavy load" do
    # Run 1000 concurrent compilations
    tasks =
      for _i <- 1..1000 do
        Task.async(fn ->
          assert {:ok, _} = SassEx.compile("div { color: blue; }")
        end)
      end

    Task.yield_many(tasks)
  end
end
