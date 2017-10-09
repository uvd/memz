defmodule MemzWeb.EventControllerTest do
  use MemzWeb.ConnCase

  alias Memz.Events

  @create_attrs %{end_date: ~N[2020-04-17 14:00:00.000000], name: "some name", owner: "some owner"}
  @invalid_attrs %{end_date: nil, name: nil, owner: nil}
  @invalid_name_attrs %{end_date: ~N[2021-05-18 15:01:01.000000], name: "s", owner: "some owner"}

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
      assert %{"id" => id} = json_response(conn, 201)["event"]

      assert json_response(conn, 201)["event"] == %{
        "id" => id,
        "end_date" => "2020-04-17T14:00:00.000000",
        "name" => "some name",
        "owner" => "some owner"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @invalid_attrs
      assert json_response(conn, 400)["event"] != %{}
    end

    test "renders error response when the name is invalid", %{conn: conn} do
      conn = post conn, event_path(conn, :create), event: @invalid_name_attrs
      assert json_response(conn, 400)["event"] == %{
          "name" => ["should be at least 4 character(s)"]
      }
    end
  end

  defp create_event(_) do
    event = fixture(:event)
    {:ok, event: event}
  end
end
