defmodule ExDocDash.Mixfile do
  use Mix.Project

  @source_url "https://github.com/JonGretar/ExDocDash"
  @version "0.3.1"

  def project do
    [
      app: :ex_doc_dash,
      name: "ExDocDash",
      version: @version,
      elixir: "~> 1.2",
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", runtime: false}
    ]
  end

  defp package do
    [
      description: "Formatter for ExDoc to generate docset documentation for use in Dash.app.",
      maintainers: ["Jón Grétar Borgþórsson"],
      licenses: ["MIT"],
      links: %{
        "Dash.app": "https://kapeli.com/dash",
        GitHub: @source_url,
        Issues: "#{@source_url}/issues"
      }
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: @version,
      homepage_url: @source_url,
      formatters: ["html"]
    ]
  end
end
