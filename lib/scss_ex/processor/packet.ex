defmodule ScssEx.Processor.Packet do
  @moduledoc """
  Sass "packets" are sent and received via :stdio.  They are LEB128 prepended
  to give a known packet length.
  """

  alias ScssEx.Processor.LEB128

  @spec parse(binary) :: :incomplete | {:ok, binary, binary}
  def parse(raw), do: do_parse(LEB128.decode(raw))

  defp do_parse({:ok, size, raw_packet}) when byte_size(raw_packet) >= size do
    <<body::binary-size(size), rest::binary>> = raw_packet

    {:ok, body, rest}
  end

  defp do_parse(_), do: :incomplete
end
