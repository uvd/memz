defmodule MemzWeb.EventController do
  use MemzWeb, :controller

  alias Memz.Events
  alias Memz.Events.Event

  action_fallback MemzWeb.FallbackController

  def create(conn, %{"event" => event_params}) do

    %{
      "name" => name,
      "owner" => owner,
      "endDateTime" => end_date_time
    } = event_params

    event_params = %{
      name: name,
      owner: owner,
      end_date: end_date_time
    }

    with {:ok, %Event{} = event} <- Events.create_event(event_params) do
      conn
      |> put_status(:created)
      |> render("show.json", event: event)
    end
  end


end
