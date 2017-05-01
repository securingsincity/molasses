if Code.ensure_loaded?(Phoenix) do
  defmodule Molasses.Router do
    use Phoenix.Router
    defmacro __using__(_opts \\ []) do
      quote do
        import unquote(__MODULE__)
      end
    end

    defmacro api_routes(_opts \\ []) do
      quote do
        post "/access", Api.ApiController, :is_active
        post "/access/:name", Api.ApiController, :is_active
        put "/:name", Api.ApiController, :update
        post "/:name", Api.ApiController, :update
        post "/", Api.ApiController, :create
        get "/", Api.ApiController, :index
      end
    end

    defmacro admin_panel_routes(_opts \\ []) do
      quote do
        get "/create", AdminPanel.AdminPanelController, :new
        get "/:name", AdminPanel.AdminPanelController, :details
        post "/:name", AdminPanel.AdminPanelController, :delete
        delete "/:name", AdminPanel.AdminPanelController, :delete
        get "/", AdminPanel.AdminPanelController, :dashboard
        post "/", AdminPanel.AdminPanelController, :create
      end
    end
  end
end
