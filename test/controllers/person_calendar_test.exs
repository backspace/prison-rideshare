defmodule PrisonRideshare.UnauthRideControllerTest do
  use PrisonRideshareWeb.ConnCase

  alias PrisonRideshareWeb.{Institution, Person, Ride}
  alias PrisonRideshare.Repo

  # setup do
  #   conn = build_conn()
  #     |> put_req_header("accept", "application/vnd.api+json")
  #     |> put_req_header("content-type", "application/vnd.api+json")
  #
  #   {:ok, conn: conn}
  # end

  test "lists all publicly-available enabled-and-not-complete-and-not-combined ride data on index", %{conn: conn} do
    institution = Repo.insert! %Institution{name: "Stony Mountain"}
    driver = Repo.insert! %Person{name: "Chelsea Manning"}
    ride = Repo.insert! %Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 15}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 15}, {20, 0, 0}}),
      institution: institution,
      driver: driver,
      address: "421 Osborne"
    }

    Repo.insert! %Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 16}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 16}, {20, 0, 0}}),
      enabled: false,
      institution: institution,
      driver: driver
    }

    # Repo.insert! %Ride{
    #   distance: 77
    # }

    Repo.insert! %Ride{
      start: Ecto.DateTime.from_erl({{2017, 1, 17}, {18, 0, 0}}),
      end: Ecto.DateTime.from_erl({{2017, 1, 17}, {20, 0, 0}}),
      institution: institution,
      driver: driver,
      address: "421 Osborne"
    }

    Repo.insert! %Ride{
      combined_with: ride,
      address: "414 Osborne"
    }

    conn = get conn, person_path(conn, :calendar, driver.id)
    assert response_content_type(conn, :calendar)
    assert response(conn, 200) == """
    BEGIN:VCALENDAR
    CALSCALE:GREGORIAN
    VERSION:2.0
    BEGIN:VEVENT
    DTEND;TZID=Etc/UTC:20170115T200000
    DTSTART;TZID=Etc/UTC:20170115T180000
    LOCATION:421 Osborne\\, 414 Osborne
    SUMMARY:Visit to Stony Mountain
    END:VEVENT
    BEGIN:VEVENT
    DTEND;TZID=Etc/UTC:20170116T200000
    DTSTART;TZID=Etc/UTC:20170116T180000
    LOCATION:
    SUMMARY:CANCELLED Visit to Stony Mountain
    END:VEVENT
    BEGIN:VEVENT
    DTEND;TZID=Etc/UTC:20170117T200000
    DTSTART;TZID=Etc/UTC:20170117T180000
    LOCATION:421 Osborne
    SUMMARY:Visit to Stony Mountain
    END:VEVENT
    END:VCALENDAR
    """
  end
end
