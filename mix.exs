defmodule Entitiex.MixProject do
  use Mix.Project

  def project do
    [
      app: :entitiex,
      version: "0.0.1",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["Andrei Lepeshkin"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/undr/entitiex"}
    ]
  end

  defp description do
    "Entitiex is an Elixir presenter library used to transform data structures. " <>
    "I'd say it's a kind of `Grape::Entity` ported from the Ruby world."
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      test: ["dialyzer", "test"]
    ]
  end
end
