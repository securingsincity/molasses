ExUnit.start()


defmodule Molasses.Test.Repo do
  use Ecto.Repo, otp_app: :molasses
end
Mix.Task.run "ecto.drop", ["--quiet", "-r", "Molasses.Test.Repo"]
Mix.Task.run "ecto.create", ["--quiet", "-r", "Molasses.Test.Repo"]
Molasses.Test.Repo.start_link

# Ecto.Adapters.SQL.begin_test_transaction(Molasses.Test.Repo)
Mix.Task.run "ecto.migrate", ["--quiet", "-r", "Molasses.Test.Repo"]

