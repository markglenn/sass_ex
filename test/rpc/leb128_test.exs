defmodule SassEx.RPC.LEB128Test do
  use ExUnit.Case

  alias SassEx.RPC.LEB128

  test "Calculates the length of a packet" do
    assert LEB128.decode(<<1, 0, 1>>) == {:ok, 1, <<0, 1>>}
    assert LEB128.decode(<<2, 0, 1>>) == {:ok, 2, <<0, 1>>}
  end

  test "Handles longer message" do
    assert LEB128.decode(<<128, 1>>) === {:ok, 128, <<>>}
    assert LEB128.decode(<<128>>) === :error
  end

  test "can encode and decode" do
    Enum.each(0..100_000, fn x ->
      result = LEB128.encode(x) |> LEB128.decode()
      assert result == {:ok, x, <<>>}
    end)
  end
end
