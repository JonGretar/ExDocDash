defmodule ExDocDash.Mixfile do
	use Mix.Project

	def project do
		[
			app: :ex_doc_dash,
			version: "0.1.0",
			elixir: "~> 1.0",
			deps: deps,
			description: description,
			package: package,
			name: "ExDocDash",
			source_url: "https://github.com/JonGretar/ExDocDash",
			homepage_url: "http://hexdocs.pm/ex_doc_dash"
		]
	end

	def application do
		[applications: [:logger]]
	end

	defp deps do
		[
			{:sqlite3, ">= 1.0.1", github: "sergey-miryanov/erlang-sqlite3"},
			{:ex_doc, ">= 0.6.1"},
			{:earmark, ">= 0.1.0"}
		]
	end

	defp description do
		"""
		Dash.app formatter for ex_doc.
		"""
	end

	defp package do
		[
			contributors: ["Jón Grétar Borgþórsson"],
			licenses: ["MIT"],
			links: %{
				"Dash.app": "http://kapeli.com/dash",
				"GitHub": "https://github.com/JonGretar/ExDocDash",
				"Issues": "https://github.com/JonGretar/ExDocDash/issues"
			}
		]
	end
end
