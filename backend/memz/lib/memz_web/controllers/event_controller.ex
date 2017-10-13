defmodule MemzWeb.EventController do
  use MemzWeb, :controller

  alias Memz.Events
  alias Memz.Events.Event
  alias Memz.Accounts
  alias MemzWeb.Guardian
  alias Memz.Repo
  alias MemzWeb.Guardian.Plug
  alias ExAws.S3
  alias Memz.Events.Uploader

  action_fallback MemzWeb.FallbackController

  def show(conn, %{"id" => id}) do

    user = Plug.current_resource(conn)
    {id, _} = Integer.parse(id)
    event = Events.get_event!(id)

    if event.user.id != user.id do
      conn
      |> put_status(:unauthorized)
      |> text("Unauthorized access")
      |> halt()
    else
      conn
      |> put_status(:ok)
      |> render("show.json", event: event)
    end

  end

  def images(conn, %{"id" => id, "_json" => input}) do
    user = %{id: 1}

    # length validation
    # list = conn.req_headers
    # # length = Enum.map(list, fn (x) -> x["content-length"] end)
    # # content_length = Enum.fetch(list, 12)
    # # content_length = elem(content_length,1)
    # # size = elem(content_length,1)
    # # {size, _} = Integer.parse(size)
    # # if size > size_limit do
    # #   halt
    # # end
    # # IO.inspect size
    #
    # IO.inspect list
    # {:ok, content_length} = Enum.fetch(list, 12)
    # size = elem(content_length,1)
    # {size, _} = Integer.parse(size)
    # if size > 8000000 do
    #   conn
    #   |> put_status(:ok)
    #   |> text("File size is too big")
    #   |> halt()
    # end



    {start, length} = :binary.match(input, ";base64,")

    raw = :binary.part(input, start + length, byte_size(input) - start - length)

    {start2, length2} = :binary.match(input, "data:")
    mime_type = :binary.part(input, start2 + length2, start - length2)

    {}String.split(input, ";base64")
    with ["image", ext] = String.split(mime_type, "/") do
      {:ok, path} = Briefly.create

      path = path <> "." <> ext

      File.write!(path, Base.decode64!(raw))

      {:ok, name} = Uploader.store({path, user})

      conn
      |> put_status(:ok)
      |> text(name)
      |> halt()
    end



#    filename = :crypto.hash(:md5, path) |> Base.encode16 |> String.downcase

#    path
#    |> S3.Upload.stream_file
#    |> S3.upload("event-images", filename <> ".jpg")
#    |> ExAws.request!




  end
  @doc """

  Create a new event but also create a new user with the name sent as "owner"

  After attempting to create the user:

  - If successful we carry on and create the event

  - If unsuccessful, because the user is sent as a string on key "owner" and the changeset will be the User changeset
    then we have to do some munging on the errors so that move the :name errors to :owner errors

  """
  def create(conn, %{"event" => %{"name" => name, "owner" => owner, "end_date" => end_date}}) do

    event_params = %{
      name: name,
      end_date: Timex.parse!(end_date, "{ISO:Extended}"),
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

    updated_changeset_with_owner_errors =
      changeset.errors
      |> Enum.filter(fn {k,_} -> k == :name end)
      |> Enum.map(&elem(&1, 1))
      |> Enum.reduce(changeset, fn ({message, keys}, acc) ->
        Ecto.Changeset.add_error(acc, :owner, message, keys)
      end)

    errors_without_name_errors =
      updated_changeset_with_owner_errors.errors
      |> Enum.filter(fn {k,_} -> k != :name end)

    {:error, %{ updated_changeset_with_owner_errors | errors: errors_without_name_errors } }

  end



end
