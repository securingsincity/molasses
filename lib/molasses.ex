defmodule Molasses do
    alias Molasses.StorageAdapter.Redis
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
        Redis.get_feature(client,key)
    end

    def activate(client, key) do
        Redis.activate(client,key)
    end

    def activate(client, key, group) do
        Redis.activate(client,key, group)
    end

    def deactivate(client, key) do
        Redis.deactivate(client,key)
    end
end
