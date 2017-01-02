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
        case Redis.get(client, key) do
            :undefined -> {:error, "failure"}
            result -> 
                [active, percentage, users] = String.split(result, "|")
                %{
                    name: key,
                    active: return_bool(active),
                    percentage: String.to_integer(percentage),
                    users: convert_to_list(users),
                }
        end
    end

    def convert_to_list(""), do: []
    def convert_to_list(non_empty_string) do
         non_empty_string 
         |> String.split(",") 
         |> Enum.map(fn (x) -> prepare_value(x) end)
    end 

    def prepare_value(x) do
        y = try do
            String.to_integer(x)
        rescue 
            _ -> x 
        end
        y
    end
    def return_bool("true"), do: true 
    def return_bool("false"), do: false 

    def activate(client, key) do
        Redis.set(client, key, "true|100|")
    end

    def activate(client, key, percentage) when is_integer(percentage) do
        Redis.set(client, key, "true|#{percentage}|")
    end

    def activate(client, key, users) when is_list(users) do
        activated_users = Enum.join(users,",")
        Redis.set(client, key, "true|100|#{activated_users}")
    end

    def activate(client, key, group) do
        Redis.set(client, key, "true|100|#{group}")
    end

    def deactivate(client, key) do
        Redis.set(client, key, "false|0|")
    end
end
