defmodule MemzWeb.EventControllerTest do
  use MemzWeb.ConnCase

  alias Memz.Events
  alias Plug.Conn
  alias MemzWeb.Guardian

  @create_attrs %{end_date: "2017-11-10T01:00", name: "SomE NAME", owner: "some owner"}
  @invalid_name_attrs %{end_date: "2017-11-10T01:00", name: "s", owner: "some owner"}

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

    test "does not return authorization header when data is not valid",  %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @invalid_name_attrs
      assert Conn.get_resp_header(conn, "authorization") |> length == 0
    end

    test "returns authorization header when data is valid", %{conn: conn} do
      
      conn = post conn, event_path(conn, :create), event: @create_attrs
      [token] = Conn.get_resp_header(conn, "authorization")
      {:ok, resource, claims} = Guardian.resource_from_token(token)
      %{"sub" => owner} = claims
      assert owner == "some owner"

    end


  end
end
