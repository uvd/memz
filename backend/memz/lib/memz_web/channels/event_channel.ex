defmodule MemzWeb.EventChannel do

  use MemzWeb, :channel
  alias MemzWeb.Guardian
  alias Memz.Events

  @default_images [
    %{ :path => "https://i.redd.it/c2co89auocrz.jpg", :owner => "Eddy", :date => ~N[2020-04-17 14:00:00.000000] }
  ]

  def images, do: @default_images


  def join("event:" <> id, payload, socket) do

    if authorized?(payload, Events.get_event!(id)) do
      {:ok, images(), socket}
    else
      {:error, %{reason: "unauthorized"}}
    end

  end
#
#  # Channels can be used in a request/response fashion
#  # by sending replies to requests from the client
#  def handle_in("ping", payload, socket) do
#    {:reply, {:ok, payload}, socket}
#  end
#
#  # It is also common to receive messages from the client and
#  # broadcast to everyone in the current topic (event:lobby).
#  def handle_in("shout", payload, socket) do
#    broadcast socket, "shout", payload
#    {:noreply, socket}
#  end

  # Add authorization logic here as required.
  defp authorized?(%{"guardian_token" => token}, event) do

    case Guardian.resource_from_token(token) do
      {:ok, user, _} -> event.user.id == user.id
      _  -> false
    end

  end

  defp authorized?(_, _) do
    false
  end

end
