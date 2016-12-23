defmodule PrisonRideshare.Integration.Requests do
  use PrisonRideshare.ConnCase

  use Hound.Helpers

  alias PrisonRideshare.Pages.NewRequest
  import NewRequest

  alias PrisonRideshare.Pages.Requests

  hound_session

  test "list requests and create one" do
    {_, milner} = Forge.saved_institution name: "Milner Ridge"

    Forge.saved_request contact: "5551212", institution: milner

    Requests.visit

    request = Requests.Requests.get(0)
    assert(Requests.Requests.contact(request) == "5551212")
    assert(Requests.Requests.institution(request) == "Milner Ridge")

    Requests.create

    NewRequest
    |> fill_start("11:30:00")
    |> fill_end("12:30:00")
    |> fill_address("91 Albert St.")
    |> fill_contact("5551313")
    |> fill_passengers("2")
    |> submit

    new_request = Requests.Requests.get(1)
    assert Requests.Requests.start(new_request) == "11:30:00"
    assert Requests.Requests.end(new_request) == "12:30:00"
    assert Requests.Requests.institution(new_request) == "ø"
  end
end
