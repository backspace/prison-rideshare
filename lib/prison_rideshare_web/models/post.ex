defmodule PrisonRideshareWeb.Post do
  use PrisonRideshareWeb, :model

  schema "posts" do
    field(:content, :string)
    belongs_to(:poster, PrisonRideshareWeb.User, foreign_key: :poster_id)

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content, :poster_id])
    |> validate_required([:content, :poster_id])
  end
end
