defmodule SassEx.RPC.Message do
  @moduledoc """
  Sass "messages" are sent and received via :stdio.  They are LEB128 prepended
  to give a known message length.
  """

  alias Sass.EmbeddedProtocol.InboundMessage
  alias SassEx.RPC.LEB128

  @spec encode(atom, any) :: binary
  @doc """
  Encode a message into a LEB128 prefixed binary message
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

  @spec decode(binary) :: :incomplete | {:ok, binary, binary}
  def decode(raw), do: do_decode(LEB128.decode(raw))

  defp do_decode({:ok, size, raw_packet}) when byte_size(raw_packet) >= size do
    <<body::binary-size(size), rest::binary>> = raw_packet

    {:ok, body, rest}
  end

  defp do_decode(_), do: :incomplete
end
