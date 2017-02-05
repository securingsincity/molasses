Code.require_file "../redis_helper.exs", __DIR__
Code.require_file "../conn_case.exs", __DIR__

defmodule Molasses.Api.ApiControllerTest do
  use Molasses.ConnCase
  alias Molasses
  alias Molasses.Test.Repo
  alias Molasses.Models.Feature
  setup do
    Application.put_env(:molasses,:adapter, "redis")
  end


  test "api_path :index should return multiple features with ecto", %{conn: conn} do
    Application.put_env(:molasses,:adapter, "ecto")
    Application.put_env(:molasses,:repo, Repo)
    Molasses.activate(Repo, "api_feature")
    Molasses.activate(Repo, "api_other_feature")

    conn = get conn, api_path(conn, :index)
    body = json_response(conn, 200)
    assert Enum.count(body["features"]) == 2
    Repo.delete_all(Feature)
  end



  test "api_path :index should return multiple features with mongo", %{conn: conn} do
    Application.put_env(:molasses,:adapter, "mongo")
    Application.put_env(:molasses,:host, "127.0.0.1")
    Application.put_env(:molasses,:port, 27017)
    Application.put_env(:molasses,:password, "")
    Application.put_env(:molasses,:database, "molasses_test")
    {:ok, client} = Mongo.start_link(database: "molasses_test")
    Molasses.activate(client, "api_feature")
    Molasses.activate(client, "api_other_feature")

    conn = get conn, api_path(conn, :index)
    body = json_response(conn, 200)
    assert Enum.count(body["features"]) == 2
    Mongo.delete_many(client, "feature_toggles", %{})
  end


  test "api_path :index should return multiple features", %{conn: conn} do
    {:ok, client} = Exredis.start_link
    Exredis.Api.flushall  client
    Molasses.activate(client, "api_feature")
    Molasses.activate(client, "api_other_feature")

    conn = get conn, api_path(conn, :index)
    body = json_response(conn, 200)
    assert Enum.count(body["features"]) == 2
  end

  test "api_path :create should create a new feature with just a name", %{conn: conn} do
    {:ok, client} = Exredis.start_link
    Exredis.Api.flushall  client
    conn = post conn, api_path(conn, :create, %{"name" => "foo"})
    json_response(conn, 201)
    assert  Molasses.is_active(client, "foo")
  end

  test "api_path :create should create a new feature with just a name and users", %{conn: conn} do
    {:ok, client} = Exredis.start_link
    Exredis.Api.flushall  client
    conn = post conn, api_path(conn, :create, %{"name" => "foo", "users" => "2,3,4"})
    json_response(conn, 201)
    assert  Molasses.is_active(client, "foo", 2)
  end

  test "api_path :create should create a new feature with just a name and percentage", %{conn: conn} do
    {:ok, client} = Exredis.start_link
    Exredis.Api.flushall  client
    conn = post conn, api_path(conn, :create, %{"name" => "foo", "percentage"=> 34})
    json_response(conn, 201)
    refute  Molasses.is_active(client, "foo", 22)
  end


  test "api_path :create should fail with no name", %{conn: conn} do
    {:ok, client} = Exredis.start_link
    Exredis.Api.flushall  client
    conn = post conn, api_path(conn, :create, %{"foo" => "foo"})
    json_response(conn, 400)
    refute  Molasses.is_active(client, "foo", 22)
  end



  test "api_path :update should update a new feature with just a name", %{conn: conn} do
    {:ok, client} = Exredis.start_link
    Exredis.Api.flushall  client
    Molasses.deactivate(client, "foo")
    conn = put conn, api_path(conn, :update, "foo"),%{"name" => "foo", "active" => true}
    json_response(conn, 204)
    assert  Molasses.is_active(client, "foo")
  end

  test "api_path :update should update a new feature with just a name and users", %{conn: conn} do
    {:ok, client} = Exredis.start_link
    Exredis.Api.flushall  client
    Molasses.deactivate(client, "foo")
    conn = put conn, api_path(conn, :update, "foo"), %{"name" => "foo", "users" => "2,3,4"}
    json_response(conn, 204)
    assert  Molasses.is_active(client, "foo", 2)
  end

  test "api_path :update should update a new feature with just a name and percentage", %{conn: conn} do
    {:ok, client} = Exredis.start_link
    Exredis.Api.flushall  client
    Molasses.activate(client, "foo")
    conn = put conn, api_path(conn, :update,"foo"), %{"name" => "foo", "percentage"=> 34}
    json_response(conn, 204)
    refute  Molasses.is_active(client, "foo", 22)
  end

  test "api_path :update should update a new feature with a name and deactivate", %{conn: conn} do
    {:ok, client} = Exredis.start_link
    Exredis.Api.flushall  client
    Molasses.activate(client, "foo")
    conn = put conn, api_path(conn, :update,"foo"), %{"name" => "foo", "active"=> false}
    json_response(conn, 204)
    refute  Molasses.is_active(client, "foo", 22)
  end

  test "api_path :update should fail if it's missing a name", %{conn: conn} do
    {:ok, client} = Exredis.start_link
    Exredis.Api.flushall  client
    Molasses.deactivate(client, "foo")
    conn = put conn, api_path(conn, :update, "foo")
    json_response(conn, 400)
    refute  Molasses.is_active(client, "foo", 22)
  end

  test "api_path :is_active should return whether a feature is active if it is", %{conn: conn} do
    {:ok, client} = Exredis.start_link
    Exredis.Api.flushall  client
    Molasses.activate(client, "foo")
    conn = post conn, api_path(conn, :is_active, "foo", %{"user_id"=> 42})
    body = json_response(conn, 200)
    assert body["active"] == true
    assert body["name"] == "foo"
  end

  test "api_path :is_active should return whether a feature is active if it is not", %{conn: conn} do
    {:ok, client} = Exredis.start_link
    Exredis.Api.flushall  client
    Molasses.activate(client, "foo", "43,45")
    conn = post conn, api_path(conn, :is_active, "foo", %{"user_id"=> 42})
    body = json_response(conn, 200)
    assert body["active"] == false
    assert body["name"] == "foo"
  end

  test "api_path :is_active should return all features", %{conn: conn} do
    {:ok, client} = Exredis.start_link
    Exredis.Api.flushall  client
    Molasses.activate(client, "foo", ["43", "45"])
    Molasses.activate(client, "bar", ["43", "42"])
    Molasses.activate(client, "baz")
    Molasses.deactivate(client, "cat")
    conn = post conn, api_path(conn, :is_active, %{"user_id" => "42"})
    body = conn
    |> json_response(200)
    |> Enum.sort(fn(x,y) -> x["name"] < y["name"] end)

    assert [
    %{"name" => "bar", "active" => true},
    %{"name" => "baz", "active" => true},
    %{"name" => "cat", "active" => false},
    %{"name" => "foo", "active" => false},] == body
  end

end