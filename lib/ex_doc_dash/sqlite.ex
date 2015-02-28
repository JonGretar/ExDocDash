defmodule ExDocDash.SQLite do
	defmodule SQLError do
		defexception message: "default message", exit_code: 1
	end

	def exec(database, query) do
		args = [database, query]
		options = [stderr_to_stdout: true]
		case System.cmd("sqlite3", args, options) do
			{results, 0}                  -> {:ok, results}
			{"Error: "<>error, exit_code} -> raise SQLError, message: error, exit_code: exit_code
			{error, exit_code}            -> raise SQLError, message: "#{error}", exit_code: exit_code
		end
	end

end
