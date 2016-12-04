defmodule Molasses.Mixfile do
  use Mix.Project

  def project do
    [app: :molasses,
     version: "0.1.0",
     elixir: "~> 1.3",
     description: description,
     package:package,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp package do
    [ files: [ "lib", "mix.exs", "README.md", "LICENSE" ],
      maintainers: [ "James Hrisho" ],
      licenses: [ "MIT" ],
      links: %{ "GitHub" => "https://github.com/securingsincity/molasses" } ]
  end

  defp description do
    """
    A feature toggle library using redis. It allows to roll out to users based on a percentage of users or alternatively to a set of users or user ids
    """
  end


  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:mix_test_watch, "~> 0.2", only: :dev},
      {:exredis, ">= 0.2.4", optional: true}
    ]
  end
end
