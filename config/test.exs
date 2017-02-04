# Print only warnings and errors during test
use Mix.Config
config :logger, level: :warn
config :molasses, Molasses.Test.Endpoint,
  http: [port: 4001],
  secret_key_base: "HL0pikQMxNSA58DV3mf26O/eh1e4vaJDmx1qLgqBcnS14gbKu9Xn3x114D+mHYcX",
  server: false
