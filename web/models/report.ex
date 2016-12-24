defmodule PrisonRideshare.Report do
  use PrisonRideshare.Web, :model

  schema "reports" do
    field :distance, :float
    field :expenses, :float
    field :notes, :string
    belongs_to :request, PrisonRideshare.Request

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:distance, :expenses, :notes])
    |> validate_required([:distance, :expenses, :notes])
  end
end