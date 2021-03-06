ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(PrisonRideshare.Repo, :manual)

defmodule Forge do
  use Blacksmith

  @save_one_function &Blacksmith.Config.save/1
  @save_all_function &Blacksmith.Config.save_all/1

  register(:ride, %PrisonRideshareWeb.Ride{
    start: Ecto.Time.from_erl({10, 0, 0}),
    end: Ecto.Time.from_erl({11, 30, 0})
  })

  register(:institution, %PrisonRideshareWeb.Institution{})

  register(:person, %PrisonRideshareWeb.Person{})
  register(:reimbursement, %PrisonRideshareWeb.Reimbursement{})
end
