defmodule PrisonRideshareWeb.SlotController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.Slot

  def index(conn, _) do
    slots = Repo.all(Slot)
    |> Repo.preload(:commitments)

    render(conn, "index.json-api", data: slots)
  end
end
