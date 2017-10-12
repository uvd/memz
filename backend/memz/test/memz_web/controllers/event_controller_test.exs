defmodule MemzWeb.EventControllerTest do
  use MemzWeb.ConnCase

  alias Memz.Events
  alias Memz.Events.Event
  alias Memz.Accounts.User
  alias Plug.Conn
  alias MemzWeb.Guardian

  alias Memz.Repo


  @create_attrs %{end_date: "2017-11-10T01:00", name: "SomE NAME", owner: "some owner"}
  @invalid_name_attrs %{end_date: "2017-11-10T01:00", name: "s", owner: "some owner"}
  @invalid_owner_attrs %{end_date: "2017-11-10T01:00", name: "s", owner: "a"}

  def fixture(:event) do
    {:ok, event} = Events.create_event(@create_attrs)
    event
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end


  describe "create event" do
    test "renders event when data is valid", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      assert json_response(conn, 201)["data"] == %{
        "id" => id,
        "end_date" => "2017-11-10T01:00:00",
        "name" => "SomE NAME",
        "slug" => "some-name",
        "owner" => "some owner"}
    end

    test "renders error response when the name is invalid", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @invalid_name_attrs
      assert json_response(conn, 400)["errors"] == %{
          "name" => ["should be at least 4 character(s)"]
      }
    end


    test "renders error response when the owner is invalid", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @invalid_owner_attrs
      assert json_response(conn, 400)["errors"] == %{
               "owner" => ["should be at least 2 character(s)"]
             }
    end

    test "does not return authorization header when data is not valid",  %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @invalid_name_attrs
      assert Conn.get_resp_header(conn, "authorization") |> length == 0
    end

    test "returns authorization header when data is valid", %{conn: conn} do

      random_number_string = :rand.uniform(1000) |> Integer.to_string

      {_, create_attrs } = Map.get_and_update(@create_attrs, :owner, fn current_value ->
        {current_value, current_value <> random_number_string }
      end)

      conn = post conn, event_path(conn, :create), event: create_attrs

      [token] = Conn.get_resp_header(conn, "authorization")
      [token|_] = token |> String.split(" ") |> Enum.reverse

      {:ok, _, claims} = Guardian.resource_from_token(token)
      %{"sub" => owner} = claims

      created_user = Repo.get_by!(User, name: create_attrs.owner)

      assert owner == Integer.to_string(created_user.id)

    end
  end

  describe "show event" do
    test "should return a 401 response when the authorization header is not set", %{conn: conn} do

      with {:ok, %Event{} = event} <- Events.create_event(@create_attrs) do

        conn = get conn, "/v1/events/" <> Integer.to_string(event.id) <> "/" <> event.slug

        assert conn.status == 401
        assert conn.resp_body == "Unauthorized access"
        assert conn.halted == true

      end

    end

    test "shows an event for the given id if authenticated", %{conn: conn} do

      event_params = %{
        name: "My new event",
        owner: "Alex",
        end_date: ~N[2020-04-17 14:00:00.000000]
      }

      resource = %{:id => "Alex"}
      {:ok, token, _} = Guardian.encode_and_sign(resource)

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)

      with {:ok, %Event{} = event} <- Events.create_event(event_params) do

        conn = get conn, "/v1/events/" <> Integer.to_string(event.id) <> "/" <> event.slug

        assert json_response(conn, 200)["data"] == %{
                 "id" => event.id,
                 "end_date" => "2020-04-17T14:00:00.000000",
                 "name" => event.name,
                 "slug" => "my-new-event",
                 "owner" => event.owner}
      end

    end
  end
end
