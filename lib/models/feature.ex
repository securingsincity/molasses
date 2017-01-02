if Code.ensure_loaded?(Ecto) do
    defmodule Molasses.Models.Feature do
        import Ecto
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