defmodule ExDocDash.Formatter.Dash.Templates do
	@moduledoc """
	Handle all template interfaces for the HTML formatter.
	"""

	require EEx

	def index() do
	end

	@doc """
	Generate content from the module template for a given `node`
	"""
	def module_page(node, config, _all) do
		types			 = node.typespecs
		functions	 = Enum.filter node.docs, &match?(%ExDoc.FunctionNode{type: :def}, &1)
		macros			= Enum.filter node.docs, &match?(%ExDoc.FunctionNode{type: :defmacro}, &1)
		callbacks	 = Enum.filter node.docs, &match?(%ExDoc.FunctionNode{type: :defcallback}, &1)
		module_template(config, node, types, functions, macros, callbacks)
	end

	@doc """
	Generates the listing.
	"""
	def list_page(scope, nodes, config, has_readme) do
		list_template(scope, nodes, config, has_readme)
	end

	# Get the full specs from a function, already in HTML form.
	defp get_specs(%ExDoc.FunctionNode{specs: specs}) when is_list(specs) do
		presence specs
	end

	defp get_specs(_node), do: nil

	# Convert markdown to HTML.
	defp to_html(nil), do: nil
	defp to_html(bin) when is_binary(bin), do: ExDoc.Markdown.to_html(bin)

	# Get the pretty name of a function node
	defp pretty_type(%ExDoc.FunctionNode{type: t}) do
		case t do
			:def					-> "function"
			:defmacro		 -> "macro"
			:defcallback	-> "callback"
			:type				 -> "type"
		end
	end

	# Generate a link id
	defp link_id(node), do: link_id(node.id, node.type)
	defp link_id(id, type) do
		case type do
			:defcallback	-> "c:#{id}"
			:type				 -> "t:#{id}"
			_						 -> "#{id}"
		end
	end

	defp node_type(:def), do: "Function"
	defp node_type(:defcallback), do: "Callback"
	defp node_type(:defmacro), do: "Macro"
	defp node_type(:type), do: "Type"
	defp node_type(_), do: "Unknown"

	defp panel_type(:def), do: "panel-success"
	defp panel_type(:defcallback), do: "panel-warning"
	defp panel_type(:defmacro), do: "panel-danger"
	defp panel_type(_), do: "panel-primary"

	defp overview_icon("Module"), do: "mdi-action-view-quilt"
	defp overview_icon("Exception"), do: "mdi-alert-warning"
	defp overview_icon("Protocol"), do: "mdi-action-extension"
	defp overview_icon(_), do: "mdi-action-help"

	# Get the first paragraph of the documentation of a node, if any.
	defp synopsis(nil), do: nil
	defp synopsis(doc) do
		String.split(doc, ~r/\n\s*\n/) |> hd |> String.strip() |> String.rstrip(?.)
	end

	defp presence([]),		do: nil
	defp presence(other), do: other

	defp h(binary) do
		escape_map = [{ ~r(&), "\\&amp;" }, { ~r(<), "\\&lt;" }, { ~r(>), "\\&gt;" }, { ~r("), "\\&quot;" }]
		Enum.reduce escape_map, binary, fn({ re, escape }, acc) -> Regex.replace(re, acc, escape) end
	end

	defp h_link(binary) do
		Regex.replace(~r(/), h(binary), "\\&#46;")
	end

	templates = [
		info_plist: [:config, :has_readme],
		list_template: [:scope, :nodes, :config, :has_readme],
		overview_template: [:config, :modules, :exceptions, :protocols],
		module_template: [:config, :module, :types, :functions, :macros, :callbacks],
		readme_template: [:config, :content],
		list_item_template: [:node],
		overview_entry_template: [:node, :type],
		summary_template: [:node],
		detail_template: [:node, :_module],
		type_detail_template: [:node, :_module],
	]

	Enum.each templates, fn({ name, args }) ->
		filename = Path.expand("templates/#{name}.eex", __DIR__)
		EEx.function_from_file :def, name, filename, args
	end
end
