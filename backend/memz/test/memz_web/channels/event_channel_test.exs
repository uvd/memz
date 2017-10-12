defmodule MemzWeb.EventChannelTest do
  use MemzWeb.ChannelCase

  alias MemzWeb.EventChannel


  describe "joining an event channel" do

    test "it should deny access if you don't give a token" do
      {:error, %{reason: reason}} =
        socket("user_id", %{some: :assign})
        |> subscribe_and_join(EventChannel, "event:lobby")

        assert reason == "unauthorized"
    end

    test "it should reply with the list of images in the event on join" do

      {:ok, initial_payload, _} =
        socket("user_id", %{some: :assign})
        |> subscribe_and_join(EventChannel, "event:lobby")

      assert initial_payload == EventChannel.images()
    end

  end

#  describe "pushes and replies" do
#
#    setup do
#      {:ok, _, socket} =
#        socket("user_id", %{some: :assign})
#        |> subscribe_and_join(EventChannel, "event:lobby")
#
#      {:ok, socket: socket}
#    end
#
#    test "ping replies with status ok", %{socket: socket} do
#      ref = push socket, "ping", %{"hello" => "there"}
#      assert_reply ref, :ok, %{"hello" => "there"}
#    end
#
#    test "shout broadcasts to event:lobby", %{socket: socket} do
#      push socket, "shout", %{"hello" => "all"}
#      assert_broadcast "shout", %{"hello" => "all"}
#    end
#
#    test "broadcasts are pushed to the client", %{socket: socket} do
#      broadcast_from! socket, "broadcast", %{"some" => "data"}
#      assert_push "broadcast", %{"some" => "data"}
#    end
#
#  end

end
