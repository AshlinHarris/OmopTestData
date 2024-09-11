module OmopTestData

using DuckDB

function main()
	con = DBInterface.connect(DuckDB.DB, ":memory:")
	pattern = r"CREATE TABLE @cdmDatabaseSchema.([\w_]*) \(([\s\S]*?)[\n\)];"
	input_file_contents = read("./assets/ddl/OMOPCDM_duckdb_5.4_ddl.sql", String)
	for match in eachmatch(pattern, input_file_contents)
		command = replace(match.match,
			"@cdmDatabaseSchema." => "",
			"integer" => "BIGINT",
		)
		DBInterface.execute(con, command)
		table_name = match.captures |> first |> String
		DBInterface.execute(con, "COPY $table_name FROM 'assets/omop-mimic-iv/1_omop_data_csv/$table_name.csv';")
	end
	#DBInterface.execute(con, """EXPORT DATABASE 'Outfiles' (FORMAT CSV, DELIMITER '|');""")
end

end # module OmopTestData
