# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :molasses, Molasses,
  repo: Molasses.Test.Repo,
  model: Molasses.Test.MockResource

config :molasses, Molasses.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "molasses_test",
  size: 10

# Print only warnings and errors during test
if Mix.env == :test do
  config :logger, level: :warn
end
