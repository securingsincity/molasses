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

end