defmodule MemzWeb.Router do
  use MemzWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    #    plug Guardian.Plug.LoadResource
  end

  pipeline :authenticated do
    plug(
      Guardian.Plug.Pipeline,
      module: MemzWeb.Guardian,
      error_handler: MemzWeb.AuthErrorHandler
    )

    plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
    plug(Guardian.Plug.EnsureAuthenticated)
    plug(Guardian.Plug.LoadResource, ensure: true)
  end

  scope "/", MemzWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  # Other scopes may use custom stacks.
  scope "/v1", MemzWeb do
    pipe_through(:api)

    resources("/events", EventController, only: [:create])
  end

  # Other scopes may use custom stacks.
  scope "/v1", MemzWeb do
    pipe_through([:api, :authenticated])

    get("/events/:id/:slug", EventController, :show)
    post("/events/:id/:slug/photos", EventController, :images)
  end
end
