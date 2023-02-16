##########################################################################
#NOTES/RESTRICTIONS

#1) RODBC CONNECTIONS CAN ONLY PULL FROM ONE DATABASE AT A TIME, UNLESS THEY ARE LINKED.
#1.1) NO USE ____; STATEMENTS CAN EXIST IN THE SQL FILES

##########################################################################
#REQUIREMENTS

#Access sql packages
require(RODBC)

##########################################################################
#INPUTS

#Identify the connection parameters
DatabaseName <- "Database"
Driver <- "SQL Server"
Server <- "Server"
Port <- "12345"

##########################################################################

#Create the connection
DriverConnect <- odbcDriverConnect(paste( "driver=", Driver, ";server=",Server,",",Port,";database=",DatabaseName,sep=""))

# Drop table if it already exists
sqlQuery(DriverConnect, "IF OBJECT_ID('Database.schema.[Table]' ) IS NOT NULL DROP TABLE Database.schema.[Table];")

#Example Data Frame
#ExampleDataFrame <- as.data.frame( rbind( c("1","2","3"),c("4","5","6")) )

# Write the data frame to the database
sqlSave(DriverConnect, ExampleDataFrame, tablename =
          "Table",rownames=FALSE, append = FALSE )

##########################################################################

#Close the Connection
odbcClose(DriverConnect)

