module OmopTestData

using DuckDB

function main()

	# Create a database in memory
	con = DBInterface.connect(DuckDB.DB, ":memory:")

	# Create a database output file
	#TODO: could do a better job managing directories and cleaning old files
	database_outfile = "out/synthea_omop_test.db"
	rm(database_outfile, force = true)
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

	# (It looks like any permission errors are due to Julia...)
	#
	# Compress to a tarball (I've been doing this manually)
	# Read and write permissions also need to be added
	# chmod 666 synthea_omop_test.db
	# tar -czvf synthea_omop_test.db.tar.gz synthea_omop_test.db
	# chmod 666 synthea_omop_test.db.tar.gz
	#run(`tar czf $(database_outfile).tar.gz $database_outfile`)
end

main()

end # module OmopTestData
