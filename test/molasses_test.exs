Code.require_file "./redis_helper.exs", __DIR__

defmodule MolassesTest do
  use ExUnit.Case
  alias Molasses
  setup do
    Application.put_env(:molasses,:adapter, "redis")
  end

  test "activate/2 sets key to 100% and sets to active" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature")
    assert Exredis.Api.get(client, "molasses_my_feature") == "true|100|"
  end

  test "activate/3 with integer sets key to percentage and activates" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", 80)
    assert Exredis.Api.get(client, "molasses_my_feature") == "true|80|"
  end

  test "activate/3 with list sets key and activates for a list of users" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", [1, 4])
    assert Exredis.Api.get(client, "molasses_my_feature") == "true|100|1,4"
  end

  test "activate/3 with string sets key and activates for a group" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", :admin)
    assert Exredis.Api.get(client, "molasses_my_feature") == "true|100|admin"
  end
  
  test "deactivate/2 sets key to 0% and sets to inactive" do
    {:ok, client} = Exredis.start_link
    Molasses.deactivate(client, "my_feature")
    assert Exredis.Api.get(client, "molasses_my_feature") == "false|0|"
  end

  test "get_feature returns get and formatted feature" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", :admin)
    assert Molasses.get_feature(client, "my_feature") == %{
      name: "my_feature",
      active: true,
      percentage: 100,
      users: ["admin"]
    }
  end

  test "get_feature returns get and formatted feature deactivated" do
    {:ok, client} = Exredis.start_link
    Molasses.deactivate(client, "my_feature")
    assert Molasses.get_feature(client, "my_feature") == %{
      name: "my_feature",
      active: false,
      percentage: 0,
      users: []
    }
  end

  test "get_feature returns get and formatted feature of users" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", [1,4])
    assert Molasses.get_feature(client, "my_feature") == %{
      name: "my_feature",
      active: true,
      percentage: 100,
      users: [1,4]
    }
  end

  test "get_feature returns get and formatted feature of users with straings" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", ["1a","a4"])
    assert Molasses.get_feature(client, "my_feature") == %{
      name: "my_feature",
      active: true,
      percentage: 100,
      users: ["1a","a4"]
    }
  end

  test "get_feature returns get and formatted feature percentage only" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", 80)
    assert Molasses.get_feature(client, "my_feature") == %{
      name: "my_feature",
      active: true,
      percentage: 80,
      users: []
    }
  end

  test "is_active/2 with valid key that is active and 100% then return true" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature")
    assert Molasses.is_active(client, "my_feature")
  end

  test "is_active/2 with valid key that is active and 80% then return false" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", 80)
    assert !Molasses.is_active(client, "my_feature")    
  end

  test "is_active/2 with valid key that is deactive return false" do
    {:ok, client} = Exredis.start_link
    Molasses.deactivate(client, "my_feature")
    assert !Molasses.is_active(client, "my_feature")
  end

  test "is_active/2 with valid key that is active for a group then return false" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", :admin)
    assert !Molasses.is_active(client, "my_feature")
  end

  test "is_active/2 with valid key that is active for a list of users then return false" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", [1, 4])
    assert !Molasses.is_active(client, "my_feature")
  end

  test "is_active/3 with integer with valid key that is active and 100% then return true" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature")
    assert Molasses.is_active(client, "my_feature", 4)
  end

  test "is_active/3 with integer  with valid key that is active and 80% then return false" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", 80)

    result = Enum.filter(1..100, fn x ->
      Molasses.is_active(client, "my_feature", x)
    end)
    assert length(result) >= 79    
    assert length(result) <= 81    
  end

  test "is_active/3 with string id  with valid key that is active and 80% then return false" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", 90)

    assert Molasses.is_active(client, "my_feature", "james")
    refute Molasses.is_active(client, "my_feature", "ZZZZ") # ""ZZZZ" equates to a 96 value in this case 
  end

  test "is_active/3 with integer  with valid key that is deactive return false" do
    {:ok, client} = Exredis.start_link
    Molasses.deactivate(client, "my_feature")
    assert !Molasses.is_active(client, "my_feature", 4)
  end


  test "is_active/3 with integer  with valid key that is active for a list of users then return true if user is in list" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", [1, 4])
    assert Molasses.is_active(client, "my_feature", 4)
  end


  test "is_active/3 with integer  with valid key that is active for a list of users then return false if user is not in list" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", [1, 3])
    assert !Molasses.is_active(client, "my_feature", 4)
  end


  test "is_active/3 with list of strings  with valid key that is active for a list of users then return false if user is not in list" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", ["abc", "bcd"])
    assert !Molasses.is_active(client, "my_feature", "cde")
  end

  test "is_active/3 with list of strings  with valid key that is active for a list of users then return true if user is in list" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", ["abc", "bcd"])
    assert Molasses.is_active(client, "my_feature", "bcd")
  end

  test "is_active/3 with string  with valid key that is active for a list of users then return false if user is not in list" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", "abc")
    assert !Molasses.is_active(client, "my_feature", "cde")
  end

  test "is_active/3 with string  with valid key that is active for a list of users then return true if user is in list" do
    {:ok, client} = Exredis.start_link
    Molasses.activate(client, "my_feature", "bcd")
    assert Molasses.is_active(client, "my_feature", "bcd")
  end

end
