defmodule Molasses.StorageAdapter.MongoDB do
    @moduledoc """
    Storage Adapter for mongodb for use in molasses
    """
  alias Molasses.Util

  def get_features(client) do
    cursor = Mongo.find(client, "feature_toggles", %{})
    Enum.to_list(cursor)
  end

  def get(client, key) do
    cursor = Mongo.find(client, "feature_toggles", %{name: key})
    case Enum.at(cursor,0) do
        0 -> nil
        result -> result
    end
  end

  def set(client, key, value) do
    Mongo.update_one!(client,
    "feature_toggles",
    %{"name": key},
    %{"$set": Map.merge(value, %{name: key})}, [upsert: true]
  )
  end

  def remove(client, key) do
    Mongo.delete_one(client, "feature_toggles", %{"name": key})
  end

  def activate(client, key) do
    set(client, key, %{
        name: key,
        percentage: 100,
        active: true
    })
  end

  def activate(client, key, percentage) when is_integer(percentage) do
    set(client, key, %{
        name: key,
        percentage: percentage,
        active: true
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
        active: true,
        users: group
    })
  end

  def deactivate(client, key) do
    set(client, key, %{
        name: key,
        percentage: 0,
        active: false,
        users: ""
    })
  end

  def get_feature(repo, key) do
    case get(repo, key) do
        nil -> {:error, "failure"}
        %{"name"=> key, "active"=> active, "percentage"=> percentage, "users"=> users} ->
            %{
                name: key,
                active: active,
                percentage: percentage,
                users: Util.convert_to_list(users),
            }
        %{"name"=> key, "active"=> active, "percentage"=> percentage} ->
            %{
                name: key,
                active: active,
                percentage: percentage,
                users: [],
            }
    end
  end

end