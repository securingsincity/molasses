if Code.ensure_loaded?(Phoenix) do
  defmodule Molasses.Api.ApiController do
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

    def index(conn, _) do
      features = repo
      |> Molasses.get_features
      |> Enum.map(fn(x) -> Map.take(x, [:active, :percentage, :name, :users]) end)

      conn
      |> put_status(200)
      |> json(%{features: features})
    end

    def create(conn, %{"name" => name, "percentage" => percentage}) when (percentage <= 100 and percentage >= 0) do
      Molasses.activate(repo, name, percentage)

      conn
      |> put_status(201)
      |> json(%{feature: name, percentage: percentage})
    end


    def create(conn, %{"name" => name, "percentage" => percentage}) do
      conn
      |> put_status(400)
      |> json(%{status: "failure", message: "invalid percentage"})
    end

    def create(conn, %{"name" => name, "users" => users}) do
      Molasses.activate(repo, name, users)

      conn
      |> put_status(201)
      |> json(%{feature: name, users: users})
    end

    def create(conn, %{"name"=> name}) do
      Molasses.activate(repo, name)

      conn
      |> put_status(201)
      |> json(%{feature: name})
    end

    def create(conn, _) do
      conn
      |> put_status(400)
      |> json(%{status: "failure"})
    end


    def update(conn,%{"name"=> name,"active" => false}) do
      Molasses.deactivate(repo, name)

      conn
      |> put_status(204)
      |> json(%{feature: name, active: false})
    end

    def update(conn,%{"name"=> name,"active" => true}) do
      Molasses.activate(repo, name)

      conn
      |> put_status(204)
      |> json(%{feature: name, active: false})
    end

    def update(conn, %{"name"=> name,"percentage" => percentage}) do
      Molasses.activate(repo, name, percentage)

      conn
      |> put_status(204)
      |> json(%{feature: name, percentage: percentage})
    end

    def update(conn, %{"name"=> name, "users" => users}) do
      Molasses.activate(repo, name, users)

      conn
      |> put_status(204)
      |> json(%{feature: name, users: users})
    end

    def update(conn,_) do
      conn
      |> put_status(400)
      |> json(%{status: "failure"})
    end

    def is_active(conn, %{"name" => name, "user_id" => user_id}) do
      is_active = Molasses.is_active(repo, name, user_id)

      conn
      |> put_status(200)
      |> json(%{active: is_active, name: name})
    end

    def is_active(conn, %{"user_id" => user_id}) do
      features = Molasses.are_features_active(repo, user_id)
       conn
      |> put_status(200)
      |> json(features)

    end
  end
end
