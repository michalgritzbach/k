defmodule Katastr.Mixfile do
  use Mix.Project

  def project do
    [
      app: :katastr,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      escript: escript_config()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :hound, :hpdf],
      mod: {Katastr.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hound, "~> 1.0.4"},
      {:floki, "~> 0.19.2"},
      {:elixlsx, "~> 0.3.0"},
      {:progress_bar, "~> 1.6"},
      {:hpdf, "~> 0.3.1"}
    ]
  end

  defp escript_config do
    [main_module: Katastr.CLI]
  end
end
