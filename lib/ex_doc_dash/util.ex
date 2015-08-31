defmodule ExDocDash.Util do

	def templates_path(other) do
		Path.expand(other, Application.app_dir(:ex_doc_dash, "priv/templates"))
	end

	def assets do
		[
			{ templates_path("stylesheets/*.css"), "stylesheets" },
			{ templates_path("javascripts/*.js"), "javascripts" },
			{ templates_path("fonts/*"), "fonts" }
		]
	end

	defmacro get_content(file_func) do
		quote bind_quoted: binding do
			defp do_get_content(unquote(:"#{file_func}")) do
				unquote(file_func)()
			end
		end
	end

end
