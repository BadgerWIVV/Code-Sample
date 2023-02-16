##########################################################################
#NOTES/RESTRICTIONS

#1) RODBC CONNECTIONS CAN ONLY PULL FROM ONE DATABASE AT A TIME, UNLESS THEY ARE LINKED.
#1.1) NO USE ____; STATEMENTS CAN EXIST IN THE SQL FILES

##########################################################################
#REQUIREMENTS

#Access sql packages
require(sqlutils)
require(RODBC)

##########################################################################
#INPUTS

#Identify the connection parameters
DatabaseName <- "Database"
Driver <- "SQL Server"
Server <- "SERVER"
Port <- "12345"

#FOR SQLUTILS - Add a folder location to access your .sql
sqlPaths("C:/Location/SQL Snippets")

##########################################################################

#Create the connection
DriverConnect <- odbcDriverConnect(paste( "driver=", Driver, ";server=",Server,",",Port,";database=",DatabaseName,sep=""))

#View available paths
sqlPaths()

#List available queries
getQueries()

#See the SQL Code in the file
getSQL("FileNameWithSQL")


#METHOD TO CALL QUERIES FORMATTED IN ROXYGEN2. Executing a query that has /* */ comments and/or parameters will error out
execQuery("FileNameWithSQL", connection = DriverConnect)

#ANOTHER METHOD TO CALL QUERIES FROM A FILE
sqlQuery(DriverConnect,getSQL("FileNameWithSQL"))

##########################################################################

#Close the Connection
odbcClose(DriverConnect)