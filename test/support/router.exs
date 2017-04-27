defmodule Molasses.Test.Router do
  use Phoenix.Router
  use Molasses.Router


  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end
  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Molasses do
    pipe_through [:api]
    api_routes()
  end
end
