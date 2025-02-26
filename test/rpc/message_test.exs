defmodule SassEx.RPC.MessageTest do
  use ExUnit.Case

  alias SassEx.RPC.LEB128
  alias SassEx.RPC.Message

  describe "encode/2" do
    alias Sass.EmbeddedProtocol.InboundMessage

    test "encode a simple message" do
      request = %InboundMessage.CompileRequest{}
      message = Message.encode(:compile_request, request, 1)

      assert message == <<3, 1, 18, 0>>
      assert LEB128.decode(message) == {:ok, 3, <<1, 18, 0>>}
    end
  end

  describe "decode/2" do
    alias Sass.EmbeddedProtocol.OutboundMessage

    test "decodes a simple message" do
      assert {:ok, 1,
              %OutboundMessage{
                message:
                  {:compile_response,
                   %OutboundMessage.CompileResponse{
                     result: {:success, %OutboundMessage.CompileResponse.CompileSuccess{}}
                   }}
              }, ""} == Message.decode(<<5, 1, 18, 2, 18, 0>>)
    end
  end
end
