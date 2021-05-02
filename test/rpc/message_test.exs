defmodule SassEx.RPC.MessageTest do
  use ExUnit.Case

  alias SassEx.RPC.LEB128
  alias SassEx.RPC.Message

  describe "encode/2" do
    alias Sass.EmbeddedProtocol.InboundMessage

    test "encode a simple message" do
      request = InboundMessage.CompileRequest.new(%{})
      message = Message.encode(:compileRequest, request)

      assert message == <<2, 18, 0>>
      assert LEB128.decode(message) == {:ok, 2, <<18, 0>>}
    end
  end

  describe "decode/2" do
    alias Sass.EmbeddedProtocol.OutboundMessage

    test "decodes a simple message" do
      assert {:ok,
              %OutboundMessage{
                message: {:compileResponse, %OutboundMessage.CompileResponse{id: 0, result: nil}}
              }, ""} == Message.decode(<<2, 18, 0>>)
    end
  end
end
