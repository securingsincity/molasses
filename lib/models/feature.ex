if Code.ensure_loaded?(Ecto) do
  defmodule Molasses.Models.Feature do
    @moduledoc """
      Defines the ecto model that makes up a feature.
    """
    import Ecto.Changeset
    use Ecto.Schema
    schema "features" do
      field :name, :string
      field :percentage, :integer
      field :users, :string
      field :active, :boolean
    end
    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [:name, :percentage, :users, :active])
    end
  end
end
