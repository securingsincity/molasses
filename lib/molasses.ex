defmodule Molasses do
  alias Molasses.StorageAdapter.Redis
  alias Molasses.StorageAdapter.Postgres
  alias Molasses.StorageAdapter.MongoDB
  @moduledoc ~S"""

  A feature toggle library using redis or SQL (using Ecto) as a backing service. It allows you to roll out to users based on a percentage. Alternatively, you can use Molasses to deploy to a group of users or user ids.

  ## Installation

  1. Add `molasses` to your list of dependencies in `mix.exs` and run `mix deps.get`:

  ```elixir
  def deps do
    [{:molasses, "~> 0.2.0"}]
  end
  ```
  2. Install related dependencies by including `ExRedis`, `MongoDB` or `Ecto` and one of its adapter libraries for Postgres or Mysql.

  2A. Redis

  For Redis, you will just need to include exredis:
  ```elixir
  def deps do
  [
  {:molasses, "~> 0.2.0"},
  {:exredis, ">= 0.2.4"}
  ]
  end
  ```

  2B. SQL using Ecto


  For Ecto with Postgres, install `ecto` and `postgrex`. You will also need to start ecto and postgrex as applications :
  ```elixir
  def deps do
  [
  {:molasses, "~> 0.2.0"},
  {:ecto, "~> 2.1.1"},
  {:postgrex, ">= 0.0.0"}
  ]
  end

  def application do
  [applications: [:ecto, :postgrex]]
  end
  ```

  Your config will also need to change. You will need to set up an Ecto Repo like you would [here](https://hexdocs.pm/ecto/Ecto.html#module-repositories). As well as set the Molasses adapter to postgres.

  ```elixir
  # molasses adapter setting
  config :molasses, adapter: "ecto"
  ```

  You will need to create an ecto migration and add the features tables.

  ```elixir

  defmodule Repo.CreateTestMocks do
  use Ecto.Migration

  def change do
  create table(:features) do
  add :name, :string
  add :percentage, :integer
  add :users, :string
  add :active, :boolean
  end

  create index(:features, [:name])
  end
  end
  ```

  2C. MongoDB

  ```elixir
  def deps do
  [
  {:molasses, "~> 0.2.0"},
  {:mongodb, ">= 0.0.0"},
  ]
  end
  ```



  ## Usage

  Molasses uses the same interface whether you are using Redis or SQL. Each function takes an `Ecto.Repo` or the `ExRedis` client as the first argument.

  """

  @doc """
  Check to see if a feature is active for all users.
  """
  def is_active(client, key) do
    case get_feature(client, key) do
      {:error, _} -> false
      %{active: false} -> false
      %{active: true,percentage: 100, users: []} -> true
      %{active: true,percentage: 100} -> false
      %{active: true,percentage: _} -> false
    end
  end
  defp get_id(id) when is_integer(id), do: Integer.to_string(id)
  defp get_id(id), do: id
  @doc """
  Check to see if a feature is active for a specific user.
  """
  def is_active(client, key, id)  do
    feature = get_feature(client, key)
    is_feature_active(feature,id)
  end

  defp is_feature_active(feature, id) do
    id = get_id id
    case feature do
      {:error, _} -> false
      %{active: false} -> false
      %{active: true,percentage: 100, users: []} -> true
      %{active: true,percentage: 100, users: users} -> Enum.member?(users, id)
      %{active: true,percentage: percentage} when is_bitstring(id) ->
        value = id |> :erlang.crc32 |> rem(100) |> abs
        value <= percentage
    end
  end

  def are_features_active(client, id) do
    features = get_features(client)
    Enum.map(features, fn(x) ->
      %{
        name: x[:name],
        active: is_feature_active(x, id)
      }
    end)
  end
  @doc """
  Returns a struct of the feature in question.
  """
  def get_feature(client, key) do
    adapter().get_feature(client,key)
  end

  @doc """
  Activates a feature for all users.
  """
  def activate(client, key) do
    adapter().activate(client,key)
  end

  @doc """
  Activates a feature for some users.
  When the group argument is an integer then it sets the feature active for a percentage of users.
  When the group argument is a string then it sets a feature active for that specific user or user group.
  When the group argument is a list then it sets a feature active for that specific list of users or user groups

  ## Examples

  # activate a feature for a percentage of users
  Molasses.activate(client, "my_feature", 75)

  # activate a feature for a subset of integer based userIds
  Molasses.activate(client, "my_feature", [2, 4, 5])

  # activate a feature for a subset of string based userIds (think a mongoId) or a list of groups
  Molasses.activate(client, "my_feature", ["admins", "super admins"])

  # activate a feature for only one group of users
  Molasses.activate(client, "my_feature", "powerusers")
  """
  def activate(client, key, group) do
    adapter().activate(client, key, group)
  end

  @doc """
  Dectivates a feature for all users.
  """
  def deactivate(client, key) do
    adapter().deactivate(client, key)
  end

  def get_features(client) do
    adapter().get_features(client)
  end


  def adapter do
    case Application.get_env(:molasses, :adapter) do
      "ecto" -> Postgres
      "mongo" -> MongoDB
      _      ->  Redis
    end
  end
end
