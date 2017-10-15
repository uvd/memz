defmodule Memz.Mixfile do
  use Mix.Project

  def project do
    [
      app: :memz,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Memz.Application, []},
      extra_applications: [:logger, :runtime_tools, :timex, :guardian]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:exfmt, "~> 0.5.0"},
      {:mix_test_watch, "~> 0.3", only: [:dev, :test], runtime: false},
      {:dogma, "~> 0.1", only: [:dev, :test]},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:distillery, "~> 1.5", runtime: false},
      {:cors_plug, "~> 1.2"},
      {:timex, "~> 3.1"},
      {:guardian, "~> 1.0-beta"},
      {:ecto_autoslug_field, "~> 0.3"},
      {:arc, "~> 0.8"},
      {:briefly, "~> 0.3"},

      # If using Amazon S3:
      {:ex_aws, "~> 1.1"},
      {:hackney, "~> 1.6"},
      {:poison, "~> 3.1"},
      {:sweet_xml, "~> 0.6"},
      {:arc_ecto, "~> 0.7.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
