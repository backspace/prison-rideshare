defmodule PrisonRideshare.RequestController do
  use PrisonRideshare.Web, :controller

  alias PrisonRideshare.{Institution, Person, Request}

  def index(conn, _params) do
    requests = Request.sorted(Request)
    |> Repo.all
    |> Repo.preload(:institution)
    |> Repo.preload(:driver)
    |> Repo.preload(:car_owner)
    render(conn, "index.html", requests: requests)
  end

  def new(conn, _params) do
    changeset = Request.changeset(%Request{})
    institutions = Repo.all(Institution)
    render(conn, "new.html", institutions: institutions, people: people, changeset: changeset)
  end

  def create(conn, %{"request" => request_params}) do
    changeset = Request.changeset(%Request{}, request_params)
    institutions = Repo.all(Institution)

    case Repo.insert(changeset) do
      {:ok, _request} ->
        conn
        |> put_flash(:info, "Request created successfully.")
        |> redirect(to: request_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", institutions: institutions, people: people, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    request = Repo.get!(Request, id)
    |> Repo.preload(:institution)
    |> Repo.preload(:driver)
    |> Repo.preload(:car_owner)
    |> Repo.preload(:combined_with)

    render(conn, "show.html", request: request)
  end

  def edit(conn, %{"id" => id}) do
    request = Repo.get!(Request, id)
    changeset = Request.changeset(request)
    institutions = Repo.all(Institution)
    render(conn, "edit.html", request: request, institutions: institutions, people: people, changeset: changeset)
  end

  def update(conn, %{"id" => id, "request" => request_params}) do
    request = Repo.get!(Request, id)
    changeset = Request.changeset(request, request_params)
    institutions = Repo.all(Institution)

    case Repo.update(changeset) do
      {:ok, request} ->
        conn
        |> put_flash(:info, "Request updated successfully.")
        |> redirect(to: request_path(conn, :show, request))
      {:error, changeset} ->
        render(conn, "edit.html", request: request, institutions: institutions, people: people, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    request = Repo.get!(Request, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(request)

    conn
    |> put_flash(:info, "Request deleted successfully.")
    |> redirect(to: request_path(conn, :index))
  end

  defp people do
    Person.sorted(Person) |> Repo.all
  end
end
