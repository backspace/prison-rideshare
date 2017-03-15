defmodule PrisonRideshare.Reimbursement do
  use PrisonRideshare.Web, :model

  schema "reimbursements" do
    field :car_amount, Money.Ecto.Type
    field :food_amount, Money.Ecto.Type
    belongs_to :person, PrisonRideshare.Person
    belongs_to :ride, PrisonRideshare.Ride

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    # FIXME the JaSerializer generator didn’t include person_id here, probably wrong but
    # currently relied upon in import code. (And ride_id now too.)
    |> cast(params, [:car_amount, :food_amount, :person_id, :ride_id])
  end
end
