defmodule MemzWeb.AuthErrorHandler do
  @moduledoc false

  import Plug.Conn
  use Phoenix.Controller, namespace: MemzWeb

  def auth_error(conn, {type, reason}, _opts) do

    IO.inspect("WHY YOU NO WORK!?")
    IO.inspect(get_req_header(conn, "authorization"))
    IO.inspect("WHY YOU NO WORK!?")

    conn
    |> put_status(:unauthorized)
    |> text("Unauthorized access")
    |> halt()
  end

end
