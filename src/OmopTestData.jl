module OmopTestData

using DuckDB

function main()
	con = DBInterface.connect(DuckDB.DB, ":memory:")
	pattern = r"CREATE TABLE @cdmDatabaseSchema.([\w_]*) \(([\s\S]*?)[\n\)];"
	input_file_contents = read("./assets/ddl/OMOPCDM_duckdb_5.4_ddl.sql", String)
	all_match_positions = findall(pattern, input_file_contents)
	all_match_strings = String[input_file_contents[position] for position in all_match_positions]
	for match in all_match_strings
		command = replace(match, "@cdmDatabaseSchema." => "")
		DBInterface.execute(con, command)
	end
	DBInterface.execute(con, """EXPORT DATABASE 'Outfiles' (FORMAT CSV, DELIMITER '|');""")
end

end # module OmopTestData
