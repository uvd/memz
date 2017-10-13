defmodule MemzWeb.EventChannelTest do
  use MemzWeb.ChannelCase

  alias MemzWeb.EventChannel
  alias Memz.Accounts
  alias MemzWeb.Guardian
  alias Memz.Events
  alias Memz.Events.Image
  alias Memz.Repo

  describe "joining an event channel" do

    setup do

      {:ok, user } = Accounts.create_user(%{"name" => "Eddy"})
      {:ok, token, _} = Guardian.encode_and_sign(user)
      {:ok, event } = Events.create_event(%{ "name" => "Eddys Birthday Party", "end_date" => ~N[2020-04-17 14:00:00.000000], "user_id" => user.id })

      image_attrs = %{"file" => "test.png", "user_id" => user.id, "event_id" => event.id }

      {:ok, image } = %Image{}
      |> Image.dummy_changeset(image_attrs)
      |> Repo.insert()

      {:ok, token: token, event_id: event.id |> Integer.to_string, images: [image] }
    end


    test "it should deny access if you don't give a token", %{token: token, event_id: event_id} do
      {:error, %{reason: reason}} =

        socket()
        |> subscribe_and_join(EventChannel, "event:" <> event_id)

        assert reason == "unauthorized"
    end

    test "it should deny access if you don't give the token for the owner of the event", %{token: token, event_id: event_id} do
      {:error, %{reason: reason}} =

        socket()
        |> subscribe_and_join(EventChannel, "event:" <> event_id, %{"guardian_token" => "not_event_owner_token"})

      assert reason == "unauthorized"
    end

    test "it should reply with the list of images in the event on join", %{token: token, event_id: event_id, images: images} do

      {:ok, initial_payload, _} =

        socket()
        |> subscribe_and_join(EventChannel, "event:" <> event_id, %{"guardian_token" => token})

      assert initial_payload == images
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
