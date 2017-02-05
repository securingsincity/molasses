defmodule Molasses.StorageAdapter.MongoTest do
  use ExUnit.Case
  alias Molasses.StorageAdapter.MongoDB
  setup do
    Application.put_env(:molasses,:adapter, "mongo")
    Application.put_env(:molasses,:host, "127.0.0.1")
    Application.put_env(:molasses,:port, 27017)
    Application.put_env(:molasses,:password, "")
    Application.put_env(:molasses,:database, "molasses_test")
  end

  test "get_all should return all features" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")
    MongoDB.activate(conn, "my_feature", "admin")
    MongoDB.activate(conn, "another_test")
    [feature1, feature2] = MongoDB.get_features(conn)
    assert feature1[:name] == "my_feature"
    assert feature2[:name] == "another_test"
    assert feature1[:users] == ["admin"]
    Mongo.delete_many(conn, "feature_toggles", %{})
  end

  test "get should return the value" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")
    Mongo.update_one(conn, "feature_toggles",
      %{"name": "foo"},
      %{"$set":
        %{
          "name": "foo",
          "percentage": 90
        }
      },[upsert: true])

    %{"name"=> name, "percentage"=> percent} = MongoDB.get(conn, "foo")
    assert percent == 90
    assert name == "foo"
    Mongo.delete_many(conn, "feature_toggles", %{})

  end

  test "get should return undefined" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")
    Mongo.update_one(conn, "feature_toggles",
      %{"name": "foo"},
      %{"$set":
        %{
          "name": "foo",
          "percentage": 90
        }
      },[upsert: true])


    result = MongoDB.get(conn, "baz")
    refute result
    Mongo.delete_many(conn, "feature_toggles", %{})
  end

  test "set should return the feature and create it if its not there" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")

    assert MongoDB.set conn, "foo", %{percentage: 80, users: "bar,baz"}
    %{"name"=> name, "percentage"=> percent, "users"=> users} = MongoDB.get(conn, "foo")
    assert percent == 80
    assert name == "foo"
    assert users == "bar,baz"

    Mongo.delete_many(conn, "feature_toggles", %{})
  end


  test "set should return the updated feature and update it in the database" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")

    assert MongoDB.set conn, "foo", %{percentage: 70, users: "bar,baz"}
    assert MongoDB.set conn, "foo", %{percentage: 80, users: "bar,cat"}
    %{"name"=> name, "percentage"=> percent, "users"=> users} = MongoDB.get(conn, "foo")
    assert percent == 80
    assert name == "foo"
    assert users == "bar,cat"

    Mongo.delete_many(conn, "feature_toggles", %{})
  end

  test "remove should remove the value from the database" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")

    MongoDB.set conn, "foo", %{percentage: 70, users: "bar,baz"}
    MongoDB.remove conn, "foo"
    assert MongoDB.get(conn, "foo") == nil
    Mongo.delete_many(conn, "feature_toggles", %{})
  end

  test "activate/2 sets key to 100% and sets to active" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")
    MongoDB.activate(conn, "my_feature")
    %{"name"=> name, "percentage"=> percent, "active" => active}  = MongoDB.get(conn, "my_feature")
    assert name == "my_feature"
    assert percent == 100
    assert active == true
    Mongo.delete_many(conn, "feature_toggles", %{})
  end

  test "activate/2 sets key to 100% and sets to active using molasses" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")
    Molasses.activate(conn, "my_feature")
    %{"name"=> name, "percentage"=> percent, "active" => active}  = MongoDB.get(conn, "my_feature")
    assert name == "my_feature"
    assert percent == 100
    assert active == true
    Mongo.delete_many(conn, "feature_toggles", %{})
  end


  test "activate/3 with integer sets key to percentage and activates" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")
    MongoDB.activate(conn, "my_feature", 80)
    %{"name"=> name, "percentage"=> percent, "active" => active}  = MongoDB.get(conn, "my_feature")
    assert name == "my_feature"
    assert percent == 80
    assert active == true
    Mongo.delete_many(conn, "feature_toggles", %{})
  end

  test "activate/3 with list sets key and activates for a list of users" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")
    MongoDB.activate(conn, "my_feature", [1, 4])
    %{"name"=> name, "percentage"=> percent, "active" => active, "users"=>users}  = MongoDB.get(conn, "my_feature")
    assert name == "my_feature"
    assert percent == 100
    assert users == "1,4"
    assert active == true
    Mongo.delete_many(conn, "feature_toggles", %{})
  end

  test "activate/3 with string sets key and activates for a group" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")
    MongoDB.activate(conn, "my_feature", "admin")
    %{"name"=> name, "percentage"=> percent, "active" => active, "users"=>users}  = MongoDB.get(conn, "my_feature")
    assert name == "my_feature"
    assert percent == 100
    assert users == "admin"
    assert active == true
    Mongo.delete_many(conn, "feature_toggles", %{})
  end


  test "deactivate/2 sets key to 0% and sets to inactive" do
     {:ok, conn} = Mongo.start_link(database: "molasses_test")
    MongoDB.deactivate(conn, "my_feature")
    %{"name"=> name, "percentage"=> percent, "active" => active, "users"=>users}  = MongoDB.get(conn, "my_feature")
    assert name == "my_feature"
    assert percent == 0
    assert users == ""
    assert active == false
    Mongo.delete_many(conn, "feature_toggles", %{})
  end


  test "activate/3 with string sets key and activates for a group using molasses" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")
    Molasses.activate(conn, "my_feature", "admin")
    %{"name"=> name, "percentage"=> percent, "active" => active, "users"=>users}  = MongoDB.get(conn, "my_feature")
    assert name == "my_feature"
    assert percent == 100
    assert users == "admin"
    assert active == true
    Mongo.delete_many(conn, "feature_toggles", %{})
  end

  test "deactivate/2 sets key to 0% and sets to inactiveusing molasses " do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")
    Molasses.deactivate(conn, "my_feature")
    %{"name"=> name, "percentage"=> percent, "active" => active, "users"=>users}  = MongoDB.get(conn, "my_feature")
    assert name == "my_feature"
    assert percent == 0
    assert users == ""
    assert active == false
    Mongo.delete_many(conn, "feature_toggles", %{})
  end


  test "get_feature returns get and formatted feature" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")
    MongoDB.activate(conn, "my_feature", "admin")
    assert MongoDB.get_feature(conn, "my_feature") == %{
      name: "my_feature",
      active: true,
      percentage: 100,
      users: ["admin"]
    }
    Mongo.delete_many(conn, "feature_toggles", %{})
  end

  test "get_feature returns get and formatted feature deactivated" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")
    MongoDB.deactivate(conn, "my_feature")
    assert MongoDB.get_feature(conn, "my_feature") == %{
      name: "my_feature",
      active: false,
      percentage: 0,
      users: []
    }
    Mongo.delete_many(conn, "feature_toggles", %{})
  end

  test "get_feature returns get and formatted feature of users" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")
    MongoDB.activate(conn, "my_feature", [1,4])
    assert MongoDB.get_feature(conn, "my_feature") == %{
      name: "my_feature",
      active: true,
      percentage: 100,
      users: ["1","4"]
    }
    Mongo.delete_many(conn, "feature_toggles", %{})
  end

  test "get_feature returns get and formatted feature of users with straings" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")
    MongoDB.activate(conn, "my_feature", ["1a","a4"])
    assert MongoDB.get_feature(conn, "my_feature") == %{
      name: "my_feature",
      active: true,
      percentage: 100,
      users: ["1a","a4"]
    }
    Mongo.delete_many(conn, "feature_toggles", %{})
  end

  test "get_feature returns get and formatted feature percentage only" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")
    MongoDB.activate(conn, "my_feature", 80)
    assert MongoDB.get_feature(conn, "my_feature") == %{
      name: "my_feature",
      active: true,
      percentage: 80,
      users: []
    }
    Mongo.delete_many(conn, "feature_toggles", %{})
  end
  test "get_feature from molasses.ex" do
    {:ok, conn} = Mongo.start_link(database: "molasses_test")
    Molasses.activate(conn, "my_feature", 80)
    assert Molasses.get_feature(conn, "my_feature") == %{
      name: "my_feature",
      active: true,
      percentage: 80,
      users: []
    }
    Mongo.delete_many(conn, "feature_toggles", %{})
  end

end