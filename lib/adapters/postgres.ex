if Code.ensure_loaded?(Ecto) do
  defmodule Molasses.StorageAdapter.Postgres do
    @moduledoc """
    Storage Adapter for Ecto for use in molasses.
    """
    alias Molasses.Models.Feature
    alias Molasses.Util
    import Ecto.Query

    def get_features(repo) do
      repo.all(from feature in Feature, select: feature)
    end

    def get(repo, key) do
      case repo.get_by(Feature, %{name: key}) do
        nil -> nil
        result -> result
      end
    end

    def set(repo, key, value) do
      case repo.get_by(Feature, %{name: key}) do
        nil ->
          result = Map.merge(%Feature{name: key},value)
          repo.insert!(result)
        result ->
          result = Feature.changeset(result,value)
          repo.update!(result)
      end
    end

    def remove(repo, key) do
      case repo.get_by(Feature, %{name: key}) do
        nil -> nil
        result ->
          repo.delete!(result)
          nil
      end
    end

    def activate(client, key) do
      set(client, key, %{
        name: key,
        active: true,
        percentage: 100,
        users: ""
        })
    end

    def activate(client, key, percentage) when is_integer(percentage) do
      set(client, key, %{
        name: key,
        active: true,
        percentage: percentage,
        users: ""
        })
    end

    def activate(client, key, users) when is_list(users) do
      activated_users = Enum.join(users,",")
      set(client, key, %{
        name: key,
        percentage: 100,
        active: true,
        users: activated_users
        })
    end

    def activate(client, key, group) do
      set(client, key, %{
        name: key,
        percentage: 100,
        users: group,
        active: true
        })
    end

    def deactivate(client, key) do
      set(client, key, %{
        name: key,
        active: false,
        percentage: 0,
        users: ""
        })
    end




    def get_feature(repo, key) do
      case get(repo, key) do
        nil -> {:error, "failure"}
        %{name: key, active: active, percentage: percentage, users: users} ->
          %{
            name: key,
            active: active,
            percentage: percentage,
            users: Util.convert_to_list(users),
          }
      end
    end
  end
end
