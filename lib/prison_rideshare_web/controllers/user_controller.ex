defmodule PrisonRideshareWeb.UserController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.User
  alias JaSerializer.Params

  plug(:scrub_params, "data" when action in [:create, :update])

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.json-api", data: users)
  end

  def create(conn, %{"data" => data = %{"type" => "users", "attributes" => _user_params}}) do
    changeset = User.changeset(%User{}, Params.to_attributes(data))

    case PaperTrail.insert(changeset, version_information(conn)) do
      {:ok, %{model: user}} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", user_path(conn, :show, user))
        |> render("show.json-api", data: user)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.json-api", data: user)
  end

  def current(conn, _) do
    user =
      conn
      |> Guardian.Plug.current_resource()

    conn
    |> render("show.json-api", data: user)
  end

  def update(conn, %{
        "id" => id,
        "data" => data = %{"type" => "users", "attributes" => _user_params}
      }) do

    case conn do
      %{private: %{guardian_default_resource: %{admin: true}}} ->
        user = Repo.get!(User, id)
        changeset = User.admin_changeset(user, Params.to_attributes(data))

        case PaperTrail.update(changeset, version_information(conn)) do
          {:ok, %{model: user}} ->
            render(conn, "show.json-api", data: user)
    
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(:errors, data: changeset)
        end
      
      _ ->
        query_params = Plug.Conn.fetch_query_params(conn)
        token = id

        # FIXME configure max age and salt?
        case Phoenix.Token.verify(PrisonRideshareWeb.Endpoint, "reset salt", token, 86400) do
          {:ok, true_id} ->
            user = Repo.get!(User, true_id)

            changeset = User.changeset(user, Params.to_attributes(data))

            case PaperTrail.update(changeset, version_information(conn)) do
              {:ok, %{model: user}} ->
                render(conn, "show.json-api", data: user)

              {:error, changeset} ->
                conn
                |> put_status(:unprocessable_entity)
                |> render(:errors, data: changeset)
            end

          {:error, _} ->
            conn
            |> put_status(:unauthorized)
            |> render(PrisonRideshareWeb.ErrorView, "401.json")    
        end
      end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    PaperTrail.delete!(user, version_information(conn))

    send_resp(conn, :no_content, "")
  end

  def reset(conn, %{"email" => email}) do
    user = Repo.get_by!(User, email: email)
    token = Phoenix.Token.sign(PrisonRideshareWeb.Endpoint, "reset salt", user.id)

    PrisonRideshare.Email.reset(user, token)
    |> PrisonRideshare.Mailer.deliver_later()

    send_resp(conn, :no_content, "")
  end
end
