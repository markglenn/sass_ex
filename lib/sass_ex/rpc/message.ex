defmodule SassEx.RPC.Message do
  @moduledoc false

  alias Sass.EmbeddedProtocol.{InboundMessage, OutboundMessage}
  alias SassEx.RPC.LEB128

  @spec encode(atom, any, integer) :: binary
  @doc """
  Encode an inbound message into a LEB128 prefixed binary message
  """
  def encode(type, message, compilation_id) do
    msg =
      %{message: {type, message}}
      |> InboundMessage.new()
      |> InboundMessage.encode()

    id = LEB128.encode(compilation_id)
    encoded_len = LEB128.encode(byte_size(msg) + byte_size(id))

    <<encoded_len::binary, id::binary, msg::binary>>
  end

  @spec decode(binary) :: :incomplete | {:ok, integer, OutboundMessage.t(), binary}
  @doc """
  Decode a LEB128 prefixed message into an `OutboundMessage`
  """
  def decode(raw) when is_binary(raw) do
    with {:ok, total_size, rest} <- LEB128.decode(raw),
         {:ok, compilation_id, raw_packet} <- LEB128.decode(rest) do
      do_decode(total_size - byte_size(rest) + byte_size(raw_packet), compilation_id, raw_packet)
    else
      _ -> :incomplete
    end
  end

  defp do_decode(size, compilation_id, raw_packet) when byte_size(raw_packet) >= size do
    <<body::binary-size(size), rest::binary>> = raw_packet
    {:ok, compilation_id, OutboundMessage.decode(body), rest}
  end

  defp do_decode(_, _, _), do: :incomplete
end
