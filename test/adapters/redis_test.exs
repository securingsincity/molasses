Code.require_file "../redis_helper.exs", __DIR__

defmodule Molasses.StorageAdapter.RedisTest do
  use ExUnit.Case
  alias Molasses.StorageAdapter.Redis
  import Exredis.Api
  setup do
    Application.put_env(:molasses,:adapter, "redis")
  end

 test "get_all should return all features" do
    {:ok, conn} = Exredis.start_link
    Exredis.Api.flushall  conn
    Redis.activate(conn, "my_feature", "admin")
    Redis.activate(conn, "another_test")
    features = Molasses.get_features(conn)
    assert Enum.count(features) == 2
  end

  test "get should return the value" do

    {:ok, client} = Exredis.start_link
    set(client, "molasses_foo", "value")
    assert Exredis.Api.get client, "molasses_foo" === "value"

    assert Redis.get( client, "foo") === "value"

  end
  test "get should return undefined" do

    {:ok, client} = Exredis.start_link
    set(client, "molasses_foo", "value")
    assert Exredis.Api.get( client, "molasses_foo") === "value"
    assert :undefined == Redis.get( client, "var")
  end

  test "set should return the value and ok if its in the database" do

    {:ok, client} = Exredis.start_link
    assert Redis.set client, "foo", "value"
    assert Exredis.Api.get( client, "molasses_foo") === "value"

  end

  test "remove should remove the value from the database" do

    {:ok, client} = Exredis.start_link
    assert Redis.set client, "foo", "value"
    assert Redis.remove client, "foo"
    assert Exredis.Api.get( client, "molasses_foo") === :undefined

  end

end