# Molasses

[![Build Status](https://travis-ci.org/securingsincity/molasses.svg?branch=master)](https://travis-ci.org/securingsincity/molasses)
[![Coverage Status](https://coveralls.io/repos/github/securingsincity/molasses/badge.svg?branch=master)](https://coveralls.io/github/securingsincity/molasses?branch=master)

A feature toggle library using redis or SQL (using Ecto) as a backing service. It allows you to roll out to users based on a percentage. Alternatively, you can use Molasses to deploy to a group of users or user ids. 

## Installation

  1. Add `molasses` to your list of dependencies in `mix.exs` and run `mix deps.get`:

    ```elixir
    def deps do
      [{:molasses, "~> 0.2.0"}]
    end
    ```
  2. Install related dependencies by including `ExRedis` or `Ecto` and one of its adapter libraries for Postgres or Mysql. 
  
  2A. Redis

      For Redis, you will just need to include exredis: 
      ```elixir
        def deps do
          [
            {:molasses, "~> 0.2.0"},
            {:exredis, ">= 0.2.4"}
          ]
        end
      ```
    
  2B. SQL using Ecto


      For Ecto with Postgres, install `ecto` and `postgrex`. You will also need to start ecto and postgrex as applications : 
      ```elixir
        def deps do
          [
            {:molasses, "~> 0.2.0"},
            {:ecto, "~> 2.1.1"},
            {:postgrex, ">= 0.0.0"}
          ]
        end

        def application do
          [applications: [:ecto, :postgrex]]
        end
      ```

      Your config will also need to change. You will need to set up an Ecto Repo like you would [here](https://hexdocs.pm/ecto/Ecto.html#module-repositories). As well as set the Molasses adapter to postgres. 

      ```elixir
      # molasses adapter setting
      config :molasses, adapter: "postgres" 
      ```


    
## Usage

Molasses uses the same interface whether you are using Redis or SQL. Each function takes an `Ecto.Repo` or the `ExRedis` client as the first argument. 

### Activate

* `activate/2` - Activates a feature for all users.
* `activate/3` -  Activates a feature for some users.
  *  When the last argument is an integer then it sets the feature active for a percentage of users. 
  *  When the last argument is a string then it sets a feature active for that specific user or user group.
  *  When the last argument is a list then it sets a feature active for that specific list of users or user groups

### Deactivate

* `deactivate/2` - Dectivates a feature for all users. 

### Checking to see if a feature is active

* `is_active/2` - Check to see if a feature is active for all users.
* `is_active/3` - Check to see if a feature is active for a specific user.


## Examples

### Redis
```elixir

# Create a new redis client
{:ok, client} = Exredis.start_link

# activate a feature
Molasses.activate(client, "my_feature")

# activate a feature for a percentage of users
Molasses.activate(client, "my_feature", 75)

# activate a feature for a subset of integer based userIds 
Molasses.activate(client, "my_feature", [2, 4, 5])

# activate a feature for a subset of string based userIds (think a mongoId) or a list of groups
Molasses.activate(client, "my_feature", ["admins", "super admins"])

# activate a feature for only one group of users
Molasses.activate(client, "my_feature", "powerusers")

# checking if a feature is active for all users
Molasses.is_active(client, "my_feature")

# checking if a feature is active for a specific user (based on percentage, or user id/group)
Molasses.is_active(client, "my_feature", identifier)

# deactivate a feature
Molasses.deactivate(client, "my_feature")
```

### Ecto

```elixir
# Switched to ecto as my adapter
Application.put_env(:molasses,:adapter, "ecto")

# alias the Repo for use
alias Molasses.Test.Repo

# use is_active and activate the same way but it uses the Ecto repo instead of 
Molasses.activate(client, "my_feature", 75)
Molasses.is_active(Repo, "my_feature")
```

