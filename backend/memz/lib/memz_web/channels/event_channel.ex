defmodule MemzWeb.EventChannel do
  use MemzWeb, :channel
  alias MemzWeb.Guardian
  alias Memz.Events
  alias Memz.Events.Event
  alias Memz.Accounts.User

  def join("event:" <> id, %{"guardian_token" => token}, socket) do
    event = Events.get_event!(id)
    rendered = MemzWeb.ImageView.render("index.json", images: event.images)

    case Guardian.resource_from_token(token) do
      {:ok, user, _} ->
        if authorized?(user, event) do
          {:ok, rendered.data, socket}
        else
          {:error, %{reason: "unauthorized"}}
        end

      _ ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  def join(_, _, _) do
    {:error, %{reason: "unauthorized"}}
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
  defp authorized?(%User{} = user, %Event{} = event) do
    event.user.id == user.id
  end

  defp authorized?(_, _) do
    false
  end
end
