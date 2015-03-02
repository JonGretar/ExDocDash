defmodule ExDocDash.SQLite do
	@moduledoc ~S"""
	Execute an SQL query using the sqlite3 command line utility.
	"""
	defmodule SQLError do
		defexception message: "default message", exit_code: 1
	end

	@type query :: String.t
	@type query_result :: String.t

	@spec create_index(Map.t) :: :ok
	def create_index(config) do
		database = config.formatter_opts[:docset_sqlitepath]
		exec!(database, "CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);")
		exec!(database, "CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);")
		:ok
	end

	@spec index_item(Map.t, String.t, String.t, String.t) :: :ok
	def index_item(config, name, type, path) do
		database = config.formatter_opts[:docset_sqlitepath]
		query = "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('#{name}', '#{type}', '#{path}');"
		exec!(database, query)
		:ok
	end

	@doc ~S"""
	Executes given query onto a database.

		{:ok, results} = ExDocDash.SQLite.exec("my.db", "SELECT * from something")
		IO.format("Results: #{results}")
	"""
	@spec exec!(String.t, query) :: query_result
	def exec!(database, query) do
		args = [database, query]
		options = [stderr_to_stdout: true]
		case System.cmd("sqlite3", args, options) do
			{results, 0}                  -> results
			{"Error: "<>error, exit_code} -> raise SQLError, message: error, exit_code: exit_code
			{error, exit_code}            -> raise SQLError, message: "#{error}", exit_code: exit_code
		end
	end

end
