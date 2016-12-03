defmodule Molasses.StorageAdapter.Redis do
    def get(client, key) do
        Exredis.Api.get client, "molasses_#{key}"
    end

    def set(client, key, value) do
        Exredis.Api.set client,  "molasses_#{key}", value
    end

    def remove(client, key) do
        Exredis.Api.del client,  "molasses_#{key}"
    end
end