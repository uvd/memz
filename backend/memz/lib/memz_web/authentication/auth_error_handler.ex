defmodule MemzWeb.AuthErrorHandler do
  @moduledoc false

  import Plug.Conn
  use Phoenix.Controller, namespace: MemzWeb

  def auth_error(conn, {type, reason}, _opts) do

    conn
    |> put_status(:unauthorized)
    |> text("Unauthorized access")
    |> halt()
  end

end
