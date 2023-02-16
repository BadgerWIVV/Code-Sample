##########################################################################
#REQUIREMENTS

#read Excel Files
library("readxl")

#Access sql packages
require("DBI")

##########################################################################
#INPUT

FilePath <- "C:/Location/Test File for Snippet Samples.xlsx"

ExcelSheetNumber <- 1

#Identify the connection parameters
Driver <- "SQL Server"
Server <- "SERVER"
DatabaseName <- "Database"
Port <- "1234"

TargetSchemaName <- "SCHEMA"
TargetTableName <- "TABLE"

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
EDScon <- DBI::dbConnect(odbc::odbc(),
                         driver = Driver,
                         server = Server,
                         database = DatabaseName,
                         port = Port
)

DIETargetTable <- paste0("IF OBJECT_ID('",DatabaseName,".",TargetSchemaName,".[",TargetTableName,"]' ) IS NOT NULL DROP TABLE ",DatabaseName,".",TargetSchemaName,".[",TargetTableName,"];")

# Drop table if it already exists
dbGetQuery( EDScon, DIETargetTable)


table_id <- DBI::Id( schema = TargetSchemaName
                     ,table = TargetTableName
)

dbGetQuery( EDScon, paste0("USE ",DatabaseName,";") )

# Write the data frame to the database
res <- DBI::dbWriteTable( conn = EDScon
                          ,name = table_id
                          ,value = Data
                          ,field.types = ColumnTypeNames
                          #,overwrite = TRUE
                          #,append = TRUE
)


##########################################################################

#Close the Connection
dbDisconnect( EDScon )