##########################################################################

#Install Packages

library(RODBC)

##########################################################################

#INPUTS

#Identify the connection parameters
DatabaseName <- "DATABASE"
Driver <- "SQL Server"
Server <- "SERVER"
Port <- "12345"

##########################################################################

#Create a test dataset

dataset<- rbind( cbind(1,2,3), cbind(4,5,6))

##########################################################################

#Connection to BISQLPD\DW

testquery<- "SELECT TOP 100 * FROM [DATABASE].[SCHEMA].[TABLE]"
channel <- odbcDriverConnect(paste( "driver=", Driver, ";server=",Server,",",Port,";database=",DatabaseName,sep=""))
testdata<- sqlQuery(channel,paste(testquery))

#Save a dataset from R into your database on MSSQL
sqlSave(DriverConnect, dataset, tablename = "your_TableName_TEST_DELETE_ME"
        ,rownames = FALSE
        ,append = TRUE
)

odbcClose(channel)

##########################################################################
#INPUTS

#Identify the connection parameters
DatabaseNameWHIO <- "DATABASE"
DriverWHIO <- "SQL Server"
ServerWHIO <- "SERVER"

##########################################################################

#RODBC connection to WHIOSQL

WHIOquery<- " select TOP 100 * FROM [DATABASE].[SCHEMA].[Table]"
channel2 <- odbcDriverConnect( paste( "driver=", DriverWHIO, ";server=", ServerWHIO, ";database=", DatabaseNameWHIO, sep = "" ) )
WHIOdata<- sqlQuery(channel2,paste(WHIOquery))

odbcClose(channel2)

##########################################################################
#Identify the connection parameters
DatabaseNameNew <- "DATABASE"
DriverNew <- "SQL Server"
ServerNew <- "SERVER"
PortNew <- "1234"

##########################################################################
#Connection to EDS-PRD-DB01

testquery<- "SELECT TOP 100 * FROM [DATABASE].[SCHEMA].[Table]"
channel <- odbcDriverConnect(paste( "driver=", Driver, ";server=",Server,",",Port,";database=",DatabaseName,sep=""))
testdata<- sqlQuery(channel,paste(testquery))

#Save a dataset from R into your database on MSSQL
sqlSave(DriverConnect, dataset, tablename = "your_TableName_TEST_DELETE_ME"
        ,rownames = FALSE
        ,append = TRUE
)

odbcClose(channel)
