defmodule Molasses.StorageAdapter.Postgres do
    alias Molasses.Models.Feature
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
            nil ->nil
            result ->
                repo.delete!(result)
                nil
        end
    end
end