Application.put_env(:molasses,:client_type, "postgres")
defmodule Molasses.StorageAdapter.PostgresTest do
    use ExUnit.Case
    alias Molasses.StorageAdapter.Postgres
    alias Molasses.Test.Repo
    alias Molasses.Models.Feature
    test "get should return the value" do
        Repo.insert!(%Feature{name: "foo", percentage: 90})
        %Feature{name: name, percentage: percent} = Postgres.get(Repo, "foo")
        assert percent == 90
        assert name == "foo"
        Repo.delete_all(Feature)
    end
    test "get should return undefined" do

       Repo.insert!(%Feature{name: "baz", percentage: 90})
       result = Postgres.get(Repo, "foo")
       refute result
       Repo.delete_all(Feature)
    end
    
   test "set should return the feature and create it if its not there" do
      
       assert Postgres.set Repo, "foo", %{percentage: 80, users: "bar,baz"}
       %Feature{name: name, percentage: percent, users: users} = Postgres.get(Repo, "foo")
       assert percent == 80
       assert name == "foo"
       assert users == "bar,baz"
       Repo.delete_all(Feature)
   end
    
    
   test "set should return the updated feature and update it in the database" do
      
       Postgres.set Repo, "foo", %{percentage: 80, users: "bar,baz"}
       Postgres.set Repo, "foo", %{percentage: 70, users: "bar,cat"}
       %Feature{name: name, percentage: percent, users: users} = Postgres.get(Repo, "foo")
       assert percent == 70
       assert name == "foo"
       assert users == "bar,cat"
       Repo.delete_all(Feature)
   end
    
   test "remove should remove the value from the database" do
       Postgres.set Repo, "foo", %{percentage: 80, users: "bar,baz"}
       Postgres.remove Repo, "foo"
       assert Postgres.get(Repo, "foo") == nil
       Repo.delete_all(Feature)
   end


   test "activate/2 sets key to 100% and sets to active" do
    Postgres.activate(Repo, "my_feature")
    %Feature{active: active, name: name, percentage: percent} = Postgres.get(Repo, "my_feature")
    assert name == "my_feature"
    assert percent == 100
    assert active == true
    Repo.delete_all(Feature)
  end

  test "activate/3 with integer sets key to percentage and activates" do
    Postgres.activate(Repo, "my_feature", 80)
    %{active: active, name: name, percentage: percent} = Postgres.get(Repo, "my_feature")
    assert name == "my_feature"
    assert percent == 80
    assert active == true
    Repo.delete_all(Feature)
  end

  test "activate/3 with list sets key and activates for a list of users" do
    Postgres.activate(Repo, "my_feature", [1, 4])
    %{active: active, name: name, percentage: percent, users: users} = Postgres.get(Repo, "my_feature")
    assert name == "my_feature"
    assert percent == 100
    assert users == "1,4"
    assert active == true
    Repo.delete_all(Feature)
  end

  test "activate/3 with string sets key and activates for a group" do
    Postgres.activate(Repo, "my_feature", "admin")
    %{active: active, name: name, percentage: percent, users: users} = Postgres.get(Repo, "my_feature")
    assert name == "my_feature"
    assert percent == 100
    assert users == "admin"
    assert active == true
    Repo.delete_all(Feature)
  end
  
  test "deactivate/2 sets key to 0% and sets to inactive" do
    Postgres.deactivate(Repo, "my_feature")
    %{active: active, name: name, percentage: percent, users: users} = Postgres.get(Repo, "my_feature")
    assert name == "my_feature"
    assert percent == 0
    assert users == ""
    assert active == false
    Repo.delete_all(Feature)
  end

   test "get_feature returns get and formatted feature" do
    
    Postgres.activate(Repo, "my_feature", "admin")
    assert Postgres.get_feature(Repo, "my_feature") == %{
      name: "my_feature",
      active: true,
      percentage: 100,
      users: ["admin"]
    }
    Repo.delete_all(Feature)
  end

  test "get_feature returns get and formatted feature deactivated" do
    Postgres.deactivate(Repo, "my_feature")
    assert Postgres.get_feature(Repo, "my_feature") == %{
      name: "my_feature",
      active: false,
      percentage: 0,
      users: []
    }
    Repo.delete_all(Feature)
  end

  test "get_feature returns get and formatted feature of users" do
    Postgres.activate(Repo, "my_feature", [1,4])
    assert Postgres.get_feature(Repo, "my_feature") == %{
      name: "my_feature",
      active: true,
      percentage: 100,
      users: [1,4]
    }
    Repo.delete_all(Feature)
  end

  test "get_feature returns get and formatted feature of users with straings" do
    Postgres.activate(Repo, "my_feature", ["1a","a4"])
    assert Postgres.get_feature(Repo, "my_feature") == %{
      name: "my_feature",
      active: true,
      percentage: 100,
      users: ["1a","a4"]
    }
    Repo.delete_all(Feature)
  end

  test "get_feature returns get and formatted feature percentage only" do
    Postgres.activate(Repo, "my_feature", 80)
    assert Postgres.get_feature(Repo, "my_feature") == %{
      name: "my_feature",
      active: true,
      percentage: 80,
      users: []
    }
    Repo.delete_all(Feature)
  end
end