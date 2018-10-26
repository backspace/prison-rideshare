defmodule PrisonRideshareWeb.PostController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.Post
  alias JaSerializer.Params

  plug(:scrub_params, "data" when action in [:create, :update])

  def index(conn, _params) do
    posts = Repo.all(Post)
    render(conn, "index.json-api", data: posts)
  end

  def create(conn, %{"data" => data = %{"type" => "people", "attributes" => _params}}) do
    resource = Guardian.Plug.current_resource(conn)
    user =
      case resource do
        %PrisonRideshareWeb.User{} -> resource
        _ -> nil
      end

    params = Params.to_attributes(data)
    |> Map.put("poster_id", user.id)

    changeset = Post.changeset(%Post{poster: user}, params)

    case PaperTrail.insert(changeset, version_information(conn)) do
      {:ok, %{model: post}} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", post_path(conn, :show, post))
        |> render("show.json-api", data: post)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end
end
