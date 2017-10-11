defmodule MemzWeb.EventController do
  use MemzWeb, :controller

  alias Memz.Events
  alias Memz.Events.Event
  alias Memz.Accounts
  alias Memz.Accounts.User

  alias MemzWeb.Guardian
  alias Memz.Repo

  action_fallback MemzWeb.FallbackController

  def create(conn, %{"event" => event_params}) do

    %{
      "name" => name,
      "owner" => owner,
      "end_date" => end_date_time
    } = event_params

    event_params = %{
      name: name,
      end_date: Timex.parse!(end_date_time, "{ISO:Extended}")
    }

    with {:ok, %User{} = user } <- Accounts.create_user(%{ "name": owner }) do

      with {:ok, token, _} <- Guardian.encode_and_sign(user),
           {:ok, %Event{} = event} <- Events.create_event(Map.put(event_params, :user_id, user.id)) do

        event = Repo.preload(event, :user)

        conn
        |> put_resp_header("authorization", "Bearer " <> token)
        |> put_status(:created)
        |> render("show.json", event: event)
      end


    else
      {:error, %Ecto.Changeset{} = changeset} ->
          {:error, {changeset | errors = changeset.errors }}
    end



  end

  def show(conn, %{"id" => id}) do

    {id, _} = Integer.parse(id)
    event = Events.get_event!(id)

    conn
    |> put_status(:ok)
    |> render("show.json", event: event)
  end

end
