defmodule Mix.Tasks.Docs.Dash do
	use Mix.Task

	@shortdoc "Generate HTML documentation for the project"
	@recursive true
	@moduledoc """
	Uses ExDoc to generate a Dash.app documentation from the docstrings extracted from
	all of the project's modules.
	"""

	@doc false
	def run(args, config \\ Mix.Project.config, generator \\ &ExDoc.generate_docs/3) do
		Mix.Task.run "compile"

		{ cli_opts, args, _ } = OptionParser.parse(args, aliases: [o: :output], switches: [output: :string])

		if args != [] do
			raise Mix.Error, message: "Extraneous arguments on the command line"
		end

		project = (config[:name] || config[:app]) |> to_string
		version = config[:version] || "dev"
		options = Keyword.merge(get_docs_opts(config), cli_opts)
		options = Dict.put(options, :formatter, ExDocDash.Formatter.Dash)

		options = if source_url = config[:source_url] do
			Keyword.put(options, :source_url, source_url)
		else
			options
		end

		options = cond do
			is_nil(options[:main]) ->
				# Try generating main module's name from the app name
				 Keyword.put(options, :main, (config[:app] |> Atom.to_string |> Mix.Utils.camelize))

			is_atom(options[:main]) ->
				Keyword.update!(options, :main, &inspect/1)

			is_binary(options[:main]) ->
				options
		end

		options = Keyword.put_new(options, :source_beam, Mix.Project.compile_path)

		index = generator.(project, version, options)
		log(index)
		index
	end

	defp log(index) do
		Mix.shell.info [:green, "Docs successfully generated."]
		Mix.shell.info [:green, "Open with the command: open -a Dash #{inspect index}"]
	end

	defp get_docs_opts(config) do
		docs = config[:docs]
		cond do
			is_function(docs, 0) -> docs.()
			is_nil(docs) -> []
			true -> docs
		end
	end

end
