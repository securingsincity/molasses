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

    def new(conn, _) do
      render(conn, "new.html")
    end

    def delete(conn, %{"name" => name}) do
      Molasses.remove(repo, name)
      parent_url = Molasses.AdminPanel.AdminPanelView.parent_url(conn, name)
      conn
      |> put_flash(:info, "Toggle deleted")
      |> redirect(to: parent_url)
    end

    def create(conn, %{"toggle" => %{"name" => name, "percentage" => percentage}}) do
      percentage = String.to_integer(percentage)

      case percentage >= 0 && percentage <= 100 do
        true ->
          Molasses.activate(repo, name, percentage)
          conn
          |> put_flash(:info, "Toggle created")
          |> redirect(to: "/" <> Enum.join(conn.path_info))
        false ->
          conn
          |> put_flash(:error, "Invalid Percentage")
          |> put_status(400)
          |> render("new.html")
      end
    end

    def create(conn, %{"toggle" => %{"name" => name, "users" => users}}) do
      Molasses.activate(repo, name, users)

      conn
      |> put_flash(:info, "Toggle created")
      |> redirect(to: Enum.join(conn.path_info))
    end

    def create(conn, %{"toggle" => %{"name"=> name}}) do
      Molasses.activate(repo, name)

      conn
      |> put_flash(:info, "Toggle created")
      |> redirect(to: Enum.join(conn.path_info))
    end

    def create(conn, params) do
      conn
      |> put_status(400)
      |> render(conn, "new.html")
    end
  end
end