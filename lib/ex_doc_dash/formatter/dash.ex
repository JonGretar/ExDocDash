defmodule ExDocDash.Formatter.Dash do
	@moduledoc """
	Provide Dash.app documentation.
	"""

	import Mix.Generator
	require ExDocDash.Util

	alias ExDocDash.Formatter.Dash.Templates
	alias ExDoc.Formatter.HTML.Autolink
	alias ExDocDash.SQLite
	alias ExDocDash.Util

	@doc """
	Generate Dash.app documentation for the given modules
	"""
	def run(modules, config)  do
		config = make_docset(config)
		output = config.output

		SQLite.create_index(config)

		generate_assets(output, config)
		generate_icon(config)
		has_readme = config.readme && generate_readme(output, modules, config)

		all = Autolink.all(modules)

		modules    = filter_list(:modules, all)
		exceptions = filter_list(:exceptions, all)
		protocols  = filter_list(:protocols, all)

		generate_overview(modules, exceptions, protocols, output, config)
		generate_list(:modules, modules, all, output, config, has_readme)
		generate_list(:exceptions, exceptions, all, output, config, has_readme)
		generate_list(:protocols, protocols, all, output, config, has_readme)

		content = Templates.info_plist(config, has_readme)
		"#{output}/../../Info.plist" |> log |> File.write(content)

		config.formatter_opts[:docset_root]
	end

	defp make_docset(config) do
		output = Path.expand(config.output)
		docset_filename = "#{config.project} #{config.version}.docset"
		docset_root = Path.join(output, docset_filename)
		docset_docpath = Path.join(docset_root, "/Contents/Resources/Documents")
		docset_sqlitepath = Path.join(docset_root, "/Contents/Resources/docSet.dsidx")
		{:ok, _} = File.rm_rf(docset_root)
		:ok = File.mkdir_p(docset_docpath)
		formatter_opts = [
			docset_docpath: docset_docpath,
			docset_root: docset_root,
			docset_sqlitepath: docset_sqlitepath
		]
		Map.merge(config, %{output: docset_docpath, formatter_opts: formatter_opts})
	end

	defp generate_overview(modules, exceptions, protocols, output, config) do
		content = Templates.overview_template(config, modules, exceptions, protocols)
		"#{output}/overview.html" |> log |> File.write(content)
	end

	@assets Enum.map Util.assets, fn({ pattern, dir }) ->
		files = Enum.map Path.wildcard(pattern), fn(file) ->
			base = Path.basename(file)
			filename = String.replace(base, ~r/\.|-/, "_", global: true)

			# embed assets
			embed_text filename, from_file: file
			file_func = "#{filename}_text" |> String.to_atom
			Util.get_content(file_func)
			base
		end
		{files, dir}
	end

	defp generate_assets(output, _config) do
		Enum.each @assets, fn({ files, dir }) ->
			output = "#{output}/#{dir}"
			File.mkdir output

			Enum.map files, fn(file) ->
				filename = String.replace(file, ~r/\.|-/, "_", global: true)
				file_func = "#{filename}_text" |> String.to_atom
				create_file "#{output}/#{file}", do_get_content(file_func)
			end
		end
	end

	embed_text :default_icon, from_file: Util.templates_path("icon.tiff")

	defp generate_icon(config) do
		destination_path = Path.join(config.formatter_opts[:docset_root], "icon.tiff")
		custom_icon_path = Path.join(config.source_root, "icon.tiff")
		if File.exists?(custom_icon_path) do
			custom_icon_path |> log |> File.cp(destination_path)
		else
			create_file destination_path, default_icon_text()
		end
	end

	defp generate_readme(output, modules, config) do
		readme_path = Path.expand(readme_path(config, config.readme))
		write_readme(output, File.read(readme_path), modules, config)
	end

	defp readme_path(config, true), do: Path.join(config.source_root, "README.md")
	defp readme_path(config, path), do: Path.join(config.source_root, path)

	defp write_readme(output, {:ok, content}, modules, config) do
		content = Autolink.project_doc(content, modules)
		readme_html = Templates.readme_template(config, content) |> pretty_codeblocks
		"#{output}/README.html" |> log |> File.write(readme_html)
		true
	end

	defp write_readme(_, _, _, _) do
		false
	end

	@doc false
	# Helper to handle plain code blocks (```...```) without
	# language specification and indentation code blocks
	def pretty_codeblocks(bin) do
		Regex.replace(~r/<pre><code\s*(class=\"\")?>/,
		bin, "<pre class=\"codeblock\">")
	end

	@doc false
	# Helper to split modules into different categories.
	#
	# Public so that code in Template can use it.
	def categorize_modules(nodes) do
		[modules: filter_list(:modules, nodes),
		exceptions: filter_list(:exceptions, nodes),
		protocols: filter_list(:protocols, nodes)]
	end

	defp filter_list(:modules, nodes) do
		Enum.filter nodes, &match?(%ExDoc.ModuleNode{type: x} when not x in [:exception, :protocol, :impl], &1)
	end

	defp filter_list(:exceptions, nodes) do
		Enum.filter nodes, &match?(%ExDoc.ModuleNode{type: x} when x in [:exception], &1)
	end

	defp filter_list(:protocols, nodes) do
		Enum.filter nodes, &match?(%ExDoc.ModuleNode{type: x} when x in [:protocol], &1)
	end

	defp filter_list(:macros, nodes) do
		Enum.filter nodes, &match?(%ExDoc.ModuleNode{type: x} when x in [:macro], &1)
	end

	defp generate_list(scope, nodes, all, output, config, has_readme) do
		Enum.each nodes, &index_list(&1, all, output, config)
		Enum.each nodes, &generate_module_page(&1, all, output, config)
		content = Templates.list_page(scope, nodes, config, has_readme)
		"#{output}/#{scope}_list.html" |> log |> File.write(content)
	end

	defp index_list(%ExDoc.FunctionNode{}=node, module, config) do
		type = case node.type do
			:def -> "Function"
			:defmacro -> "Macro"
			:defcallback -> "Callback"
			_ -> "Record"
		end
		config |> SQLite.index_item(module<>"."<>node.id, type, module<>".html#"<>node.id)
	end
	defp index_list(%ExDoc.TypeNode{}=node, module, config) do
		config |> SQLite.index_item(module<>"."<>node.id, "Type", module<>".html#"<>node.id)
	end

	defp index_list(%ExDoc.ModuleNode{type: :exception}=node, _modules, _output, config) do
		config |> SQLite.index_item(node.id, "Exception", node.id<>".html")
	end
	defp index_list(node, _modules, _output, config) do
		config |> SQLite.index_item(node.id, "Module", node.id<>".html")
		Enum.each node.docs, &index_list(&1, node.id, config)
		Enum.each node.typespecs, &index_list(&1, node.id, config)
	end

	defp generate_module_page(node, modules, output, config) do
		content = Templates.module_page(node, config, modules)
		"#{output}/#{node.id}.html" |> log |> File.write(content)
	end

	defp log(path) do
		cwd = File.cwd!
		Mix.shell.info [:green, "* creating ", :reset, Path.relative_to(path, cwd)]
		path
	end
end
