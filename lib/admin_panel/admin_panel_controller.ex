if Code.ensure_loaded?(Phoenix) do
  defmodule Molasses.AdminPanel.AdminPanelController do
    use Phoenix.Controller
    alias Molasses
    import Molasses.Router.Helpers
    alias Molasses.StorageAdapter.Postgres
    alias Molasses.StorageAdapter.Redis
    alias Molasses.StorageAdapter.MongoDB

    defp repo do
      result = adapter.create_client
      result
    end

    def adapter do
      case Application.get_env(:molasses, :adapter) do
        "ecto" -> Postgres
        "mongo" -> MongoDB
        _      ->  Redis
      end
    end

    def dashboard(conn, _) do
      features = repo
      |> Molasses.get_features
      |> Enum.map(fn(x) -> Map.take(x, [:active, :percentage, :name, :users]) end)

      render(conn, "dashboard.html", features: features)
    end

    def details(conn, %{"name" => name}) do
      feature = repo
      |> Molasses.get_feature(name)
      |> Map.take([:active, :percentage, :name, :users])

      render(conn, "details.html", feature: feature)
    end
  end
end