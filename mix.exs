defmodule PrisonRideshare.Mixfile do
  use Mix.Project

  def project do
    [app: :prison_rideshare,
     version: "0.0.1",
     elixir: "~> 1.5",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps(),
     test_coverage: [tool: ExCoveralls]]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {PrisonRideshare.Application, []},
     applications: applications(Mix.env)]
  end

  defp applications(:test), do: applications(:all) ++ [:blacksmith]
  defp applications(_all),  do:
    [:bamboo, :bamboo_smtp,
     :phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
     :phoenix_ecto, :postgrex,

     :comeonin, :timex, :sentry, :logger]

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.3.0"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},

     {:comeonin, "~> 3.0"},
     {:cors_plug, "~> 1.2.1"},
     {:csv, "~> 1.4.2"},
     {:guardian, "~> 1.0"},
     {:ja_serializer, "~> 0.12.0"},
     {:money, "~> 1.2.1"},
     {:timex, "~> 3.1.13"},
     {:bamboo, "~> 0.8"},
     {:bamboo_smtp, "~> 1.4.0"},
     {:icalendar, "~> 0.5.0"},

     {:paper_trail, "~> 0.7.7"},

     {:blacksmith, "~> 0.1"},
     {:excoveralls, "~> 0.6", only: :test},

     {:sentry, "~> 5.0.1"}]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
