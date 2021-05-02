defmodule SassEx.RPC.Message do
  @moduledoc false

  alias Sass.EmbeddedProtocol.{InboundMessage, OutboundMessage}
  alias SassEx.RPC.LEB128

  @spec encode(atom, any) :: binary
  @doc """
  Encode an inbound message into a LEB128 prefixed binary message
  """
  def encode(type, message) do
    msg =
      %{message: {type, message}}
      |> InboundMessage.new()
      |> InboundMessage.encode()

    len =
      msg
      |> byte_size()
      |> LEB128.encode()

    <<len::binary, msg::binary>>
  end

  @spec decode(binary) :: :incomplete | {:ok, OutboundMessage.t(), binary}
  @doc """
  Decode a LEB128 prefixed message into an `OutboundMessage`
  """
  def decode(raw) when is_binary(raw) do
    raw
    |> LEB128.decode()
    |> do_decode()
  end

  defp do_decode({:ok, size, raw_packet}) when byte_size(raw_packet) >= size do
    <<body::binary-size(size), rest::binary>> = raw_packet

    {:ok, OutboundMessage.decode(body), rest}
  end

  defp do_decode(_), do: :incomplete
end
