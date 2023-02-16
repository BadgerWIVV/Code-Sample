##########################################################################
#REQUIREMENTS

#read Excel Files
library("readxl")

#Access sql packages
require(RODBC)

##########################################################################
#INPUT

FilePath <- "C:/Location/Test File for Snippet Samples.xlsx"

ExcelSheetNumber <- 1

#Identify the connection parameters
DatabaseName <- "Database"
Driver <- "SQL Server"
Server <- "Server"
Port <- "12345"

TargetTableName <- "R_SNIPPET_TEST- DELETE ME"

##########################################################################
#GET THE DATA

# Create the tbl_df for each of the spreadsheets
Data <- read_excel( FilePath, sheet = excel_sheets(FilePath)[ExcelSheetNumber], col_names = TRUE, skip = 1) 

#na.exclude( as.data.frame( unique( subset(Data, select = "CLAIM NUMBER") ) ) )

##########################################################################
#DEFINE THE DATA VARIABLE TYPES FOR THE SQL SAVE

#LABEL THE DATA TYPES FOR THE COLUMNS IN ORDER
ColumnTypeNames <- as.list( c("INT", "VARCHAR(255)" ) )

#ATTRIBUTE THE COLUMN NAMES FROM THE DATA TO THE LIST OF COLUMN TYPES
names( ColumnTypeNames ) <- ( names(Data) )

##########################################################################

#Create the connection
DriverConnect <- odbcDriverConnect(paste( "driver=", Driver, ";server=",Server,",",Port,";database=",DatabaseName,sep=""))

QueryScript <- paste0("IF OBJECT_ID('Database.schema.[",TargetTableName,"]' ) IS NOT NULL DROP TABLE Database.schema.[",TargetTableName,"];")

# Drop table if it already exists
sqlQuery(DriverConnect, QueryScript  )

# Write the data frame to the database
sqlSave( DriverConnect
         ,dat = Data
         ,tablename = TargetTableName
         ,varTypes = ColumnTypeNames
         ,rownames = FALSE
         ,append = FALSE
         ,fast = TRUE
         #,colnames =  TRUE
         #,addPK = TRUE
         #,test = TRUE
         #,nastring = "NULL"
)

##########################################################################

#Close the Connection
odbcClose(DriverConnect)