defmodule MemzWeb.EventController do
  use MemzWeb, :controller

  alias Memz.Events
  alias Memz.Events.Event
  alias Memz.Accounts
  alias Memz.Accounts.User

  alias MemzWeb.Guardian
  alias Memz.Repo

  action_fallback MemzWeb.FallbackController

  def show(conn, %{"id" => id}) do

    {id, _} = Integer.parse(id)
    event = Events.get_event!(id)

    conn
    |> put_status(:ok)
    |> render("show.json", event: event)
  end

  def create(conn, %{"event" => %{"name" => name, "owner" => owner, "end_date" => end_date}}) do

    event_params = %{
      name: name,
      end_date: Timex.parse!(end_date, "{ISO:Extended}"),
      owner: owner
    }

    Accounts.create_user(%{ "name": owner })
    |> add_event_for_user(event_params, conn)

  end


  defp add_event_for_user({ :ok, user }, event_params, conn) do

    with {:ok, token, _} <- Guardian.encode_and_sign(user),
         {:ok, %Event{} = event} <- Events.create_event(Map.put(event_params, :user_id, user.id)) do


      conn
      |> put_resp_header("authorization", "Bearer " <> token)
      |> put_status(:created)
      |> render("show.json", event: Repo.preload(event, :user))

    end

  end

  defp add_event_for_user({ :error, changeset }, _, _) do

    updated_changeset =
      changeset.errors
      |> Enum.filter(fn {k,_} -> k == :name end)
      |> Enum.map(fn {_, v} -> v end)
      |> Enum.reduce(changeset, fn ({message, keys}, acc) ->
        Ecto.Changeset.add_error(acc, :owner, message, keys)
      end)

    updated_errors =
      updated_changeset.errors
      |> Enum.filter(fn {k,_} -> k != :name end)

    {:error, %{ updated_changeset | errors: updated_errors } }

  end



end
