# Molasses

A feature toggle library using redis. It allows to roll out to users based on a percentage of users or alternatively to a set of users or user ids

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `molasses` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:molasses, "~> 0.1.0"}]
    end
    ```

  2. Ensure `molasses` is started before your application:

    ```elixir
    def application do
      [applications: [:molasses]]
    end
    ```

## Usage

Using `ExRedis` create a new client and pass it into the feature toggle library

```
{:ok, client} = Exredis.start_link

# activate a feature
Molasses.activate(client, :my_feature)

# activate a feature for a percentage of users
Molasses.activate(client, :my_feature, 75)

# activate a feature for a subset of integer based userIds 
Molasses.activate(client, :my_feature, [2, 4, 5])

# activate a feature for a subset of string based userIds (think a mongoId) or a list of groups
Molasses.activate(client, :my_feature, ["reallylongid", "long id"])


# checking if a feature is active for all users
Molasses.is_active(client, :my_feature)

# checking if a feature is active for a specific user (based on percentage, or user id/group)
Molasses.is_active(client, :my_feature, identifier)

# deactivate a feature
Molasses.deactivate(client, :my_feature)

```


## To do

- [ ] - Add support for mongo in addition to redis
- [ ] - Better documentation on configuration
