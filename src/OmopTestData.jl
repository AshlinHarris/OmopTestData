module OmopTestData

using DuckDB

function main()

	# Create a database in memory
	con = DBInterface.connect(DuckDB.DB, ":memory:")

	# Create a database output file
	database_outfile = "out/synthea_omop_test.db"
	DBInterface.execute(con, """ ATTACH '$(database_outfile)' AS out_db; """)

	# Parse the ddl into individual commands
	pattern = r"CREATE TABLE @cdmDatabaseSchema.([\w_]*) \(([\s\S]*?)[\n\)];"
	input_file_contents = read("./assets/ddl/OMOPCDM_duckdb_5.4_ddl.sql", String)
	for match in eachmatch(pattern, input_file_contents)

		# Create the table
		command = replace(match.match,
			"@cdmDatabaseSchema" => "out_db",
			"integer" => "BIGINT",
		)
		DBInterface.execute(con, command)

		# Write the data
		table_name = match.captures |> first |> String |> uppercase
		DBInterface.execute(con, "COPY out_db.$table_name FROM 'assets/data/Synthea27Nj_5.4/$table_name.csv';")
	end

	# Compress to a tarball (
	run(`tar cf $(database_outfile).tar $database_outfile`)
end

main()

end # module OmopTestData
