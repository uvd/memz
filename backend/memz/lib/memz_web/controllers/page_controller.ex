defmodule MemzWeb.PageController do
  use MemzWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
