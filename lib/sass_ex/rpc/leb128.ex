defmodule SassEx.RPC.LEB128 do
  @moduledoc false

  # LEB128 (Little Endian Base 128) encoder and decoder.
  # https://en.wikipedia.org/wiki/LEB128

  @type result_t :: {:ok, non_neg_integer(), binary} | :error

  use Bitwise

  @doc """
  Encode a positive integer value into LEB128 binary format
  """
  @spec encode(non_neg_integer) :: binary
  def encode(v) when v < 128, do: <<v>>
  def encode(v), do: <<1::1, v::7, encode(v >>> 7)::binary>>

  @doc """
  Decode a binary into its integer value or return an error

  The decoder pulls out the decoded integer value and returns the remainder
  of the binary for further parsing.
  """
  @spec decode(binary) :: result_t
  def decode(packet) when is_binary(packet), do: do_decode(0, 0, packet)

  @spec do_decode(non_neg_integer(), non_neg_integer(), binary) :: result_t
  defp do_decode(value, shift, <<1::1, byte::7, rest::binary>>) do
    (value ||| byte <<< shift)
    |> do_decode(shift + 7, rest)
  end

  defp do_decode(value, shift, <<0::1, byte::7, rest::binary>>),
    do: {:ok, value ||| byte <<< shift, rest}

  defp do_decode(_, _, _), do: :error
end
