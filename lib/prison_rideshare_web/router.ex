defmodule PrisonRideshareWeb.Router do
  use PrisonRideshareWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :api do
    plug :accepts, ["json", "json-api"]
    plug PrisonRideshare.Guardian.AuthPipeline
    plug JaSerializer.Deserializer
  end

  pipeline :calendar do
    plug :accepts, ["ics", "ifb"]
  end

  pipeline :person_api do
    plug :accepts, ["json", "json-api"]
    plug PrisonRideshare.PersonGuardian.AuthPipeline
    plug JaSerializer.Deserializer
  end

  pipeline :authenticated_api do
    plug :accepts, ["json", "json-api"]
    plug PrisonRideshare.Guardian.EnsuredAuthPipeline
    plug JaSerializer.Deserializer
  end

  pipeline :admin_api do
    plug :accepts, ["json", "json-api"]
    plug PrisonRideshare.Guardian.EnsuredAuthPipeline
    plug PrisonRideshareWeb.Plugs.Admin
    plug JaSerializer.Deserializer
  end

  pipeline :admin_non_json_api do
    plug PrisonRideshare.Guardian.EnsuredAuthPipeline
    plug PrisonRideshareWeb.Plugs.Admin
  end

  pipeline :person_authenticated_api do
    plug :accepts, ["json", "json-api"]
    plug PrisonRideshare.PersonGuardian.EnsuredAuthPipeline
    plug JaSerializer.Deserializer
  end

  scope "/", PrisonRideshareWeb do
    pipe_through :calendar

    get "/rides/calendar", RideController, :calendar
    get "/people/:id/calendar", PersonController, :calendar
  end

  scope "/", PrisonRideshareWeb do
    pipe_through :api

    post "/register", RegistrationController, :create
    post "/token", SessionController, :create, as: :login

    resources "/rides", RideController, except: [:new, :edit]
    resources "/slots", SlotController, only: [:index]
  end

  scope "/", PrisonRideshareWeb do
    pipe_through :authenticated_api

    get "/users/current", UserController, :current
  end

  scope "/", PrisonRideshareWeb do
    pipe_through :person_api

    post "/people/token", PersonSessionController, :create, as: :person_login
    get "/people/me", PersonSessionController, :show, as: :person_identify
  end

  scope "/", PrisonRideshareWeb do
    pipe_through :admin_api

    resources "/debts", DebtController, only: [:index, :delete]
    resources "/institutions", InstitutionController, except: [:new, :edit]
    resources "/people", PersonController, except: [:new, :edit]
    resources "/reimbursements", ReimbursementController, except: [:new, :edit]
    resources "/users", UserController, expect: [:new, :edit]
  end

  scope "/", PrisonRideshareWeb do
    pipe_through :admin_non_json_api

    put "/people/:id/calendar-email/:month", PersonController, :email_calendar_link, as: :person_calendar_email
  end

  scope "/", PrisonRideshareWeb do
    pipe_through :person_authenticated_api

    resources "/commitments", CommitmentController, only: [:show, :create, :delete]
  end
end
