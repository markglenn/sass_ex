defmodule SassEx.Processor.Packet do
  @moduledoc """
  Sass "packets" are sent and received via :stdio.  They are LEB128 prepended
  to give a known packet length.
  """

  alias SassEx.Processor.LEB128

  alias Sass.EmbeddedProtocol.InboundMessage

  @spec encode(atom, any) :: binary
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

  @spec parse(binary) :: :incomplete | {:ok, binary, binary}
  def parse(raw), do: do_parse(LEB128.decode(raw))

  defp do_parse({:ok, size, raw_packet}) when byte_size(raw_packet) >= size do
    <<body::binary-size(size), rest::binary>> = raw_packet

    {:ok, body, rest}
  end

  defp do_parse(_), do: :incomplete
end
