defmodule Molasses do
    alias Molasses.StorageAdapter.Redis
    alias Molasses.StorageAdapter.Postgres
    def is_active(client, key) do
        case get_feature(client, key) do
            {:error, _} -> false
            %{active: false} -> false
            %{active: true,percentage: 100, users: []} -> true
            %{active: true,percentage: 100} -> false
            %{active: true,percentage: _} -> false  
        end
    end
    
    def is_active(client, key, id)  do
        case get_feature(client, key) do
            {:error, _} -> false
            %{active: false} -> false
            %{active: true,percentage: 100, users: []} -> true
            %{active: true,percentage: 100, users: users} -> Enum.member?(users, id)
            %{active: true,percentage: percentage} when is_integer(id) ->
                value = Integer.to_string(id) |> :erlang.crc32 |> rem(100) |> abs
                value <= percentage
            %{active: true,percentage: percentage} when is_bitstring(id) ->
                value = id |> :erlang.crc32 |> rem(100) |> abs
                value <= percentage
        end
    end

    def get_feature(client, key) do
        case Application.get_env(:molasses, :adapter) do
             "ecto" -> Postgres.get_feature(client,key)
              _ ->  Redis.get_feature(client,key)
        end
    end

    def activate(client, key) do
        case Application.get_env(:molasses, :adapter) do
             "ecto" -> Postgres.activate(client,key)
              _ ->  Redis.activate(client,key)
        end
    end

    def activate(client, key, group) do
        case Application.get_env(:molasses, :adapter) do
             "ecto" -> Postgres.activate(client,key, group)
              _ ->  Redis.activate(client,key, group)
        end
    end

    def deactivate(client, key) do
        case Application.get_env(:molasses, :adapter) do
             "ecto" -> Postgres.deactivate(client,key)
              _ ->  Redis.deactivate(client,key)
        end
    end
end
