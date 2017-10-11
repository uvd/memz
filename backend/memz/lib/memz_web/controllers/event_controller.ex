defmodule MemzWeb.EventController do
  use MemzWeb, :controller

  alias Memz.Events
  alias Memz.Events.Event
  alias MemzWeb.Guardian

  action_fallback MemzWeb.FallbackController

  def create(conn, %{"event" => event_params}) do

    %{
      "name" => name,
      "owner" => owner,
      "end_date" => end_date_time
    } = event_params

    event_params = %{
      name: name,
      owner: owner,
      end_date: Timex.parse!(end_date_time, "{ISO:Extended}")
    }

    resource = %{:id => owner}

    {:ok, token, _} = Guardian.encode_and_sign(resource)

    with {:ok, %Event{} = event} <- Events.create_event(event_params) do
      conn
      |> put_resp_header("authorization", token)
      |> put_status(:created)
      |> render("show.json", event: event)
    end
  end

  def show(conn, _params) do
    conn
    |> put_status(:ok)
    |> text("Okie dokie")
    |> halt()
  end

end
