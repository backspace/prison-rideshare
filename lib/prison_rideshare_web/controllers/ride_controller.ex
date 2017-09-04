defmodule PrisonRideshareWeb.RideController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.Ride
  alias JaSerializer.Params

  import Ecto.Query

  plug :scrub_params, "data" when action in [:create, :update]
  plug PrisonRideshareWeb.Plugs.Admin when not action in [:index, :update]

  def index(%{private: %{guardian_default_resource: %{admin: true}}} = conn, _params) do
    rides = Repo.all(Ride)
    |> preload

    conn
    |> render("index.json-api", data: rides)
  end

  def index(conn, _) do
    rides = Repo.all from r in Ride, where: r.enabled and is_nil(r.distance) and is_nil(r.combined_with_ride_id), preload: [:institution, :driver]

    conn
    |> put_view(PrisonRideshareWeb.UnauthRideView)
    |> render("index.json-api", data: rides)
  end

  def create(conn, %{"data" => data = %{"type" => "rides", "attributes" => _ride_params}}) do
    changeset = Ride.changeset(%Ride{}, Params.to_attributes(data))

    case PaperTrail.insert(changeset, version_information(conn)) do
      {:ok, %{model: ride}} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ride_path(conn, :show, ride))
        |> render("show.json-api", data: ride |> preload)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    ride = Repo.get!(Ride, id)
    |> preload
    render(conn, "show.json-api", data: ride)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "rides", "attributes" => _ride_params}}) do
    ride = Repo.get!(Ride, id)
    |> preload

    fixed_params = rename_combined_with(Params.to_attributes(data))

    {changeset, conn} = case conn do
      %{private: %{guardian_default_resource: %{admin: true}}} -> {Ride.changeset(ride, fixed_params), conn}
      _ -> {Ride.report_changeset(ride, fixed_params), put_view(conn, PrisonRideshareWeb.UnauthRideView)}
    end

    case PaperTrail.update(changeset, version_information(conn)) do
      {:ok, %{model: ride}} ->
        ride = preload(ride)
        render(conn, "show.json-api", data: ride)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    ride = Repo.get!(Ride, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    PaperTrail.delete!(ride, version_information(conn))

    send_resp(conn, :no_content, "")
  end

  defp preload(model) do
    model
    |> Repo.preload([:institution, :driver, :car_owner, :children, [reimbursements: [:person, :ride]]], force: true)
  end

  # FIXME figure out where this magic is broken
  defp rename_combined_with(params) do
    Map.put(params, "combined_with_ride_id", params["combined_with_id"])
  end
end