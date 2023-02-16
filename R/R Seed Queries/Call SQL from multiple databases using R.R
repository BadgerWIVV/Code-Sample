require( "DBI")

con1 <- DBI::dbConnect(odbc::odbc(),
                             driver = "SQL Server",
                             server = "SERVER",
                             database = "DATABASE",
                             #port = 12345
                              )

con2 <- DBI::dbConnect(odbc::odbc(),
                      driver = "SQL Server",
                      server = "SERVER",
                      #database = "DATABASE",
                      #port = 1234
                      )


con3 <- DBI::dbConnect(odbc::odbc(),
                          driver = "SQL Server",
                          server = "SERVER"
                          # database = "DATABASE"
                          )

query <- "SELECT TOP 1 * FROM DATABASE.SCHEMA.TABLE"

#Executes the query
dbGetQuery( con2, query)

#Save dataframe to table
#Can write to various schemas by using Id().
#You must declare the database with a USE query prior to the write. 
  #CAUTION: The name parameter within the dbWriteTable checks for any schema and name combination regardless of database


df <- data.frame(id=1, word_of_day = "happy")

table_id <- DBI::Id( schema = "SCHEMA"
                    ,name = "IMPORTED_TABLE"
                    )

dbGetQuery( con2, "USE DATABASE;")

# Try with Id
res <- DBI::dbWriteTable( conn = con2
                         ,name = table_id
                         ,value = df
                         #,overwrite = TRUE
                         #,append = TRUE
                         )


#Disconnects the connection
dbDisconnect( con2 )

dbDisconnect( con1 )

dbDisconnect( con3 )