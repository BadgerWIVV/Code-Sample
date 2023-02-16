# https://hiratake55.wordpress.com/2013/03/28/rforcecom/

install.packages("RForcecom")
#  this installed OK for me on 4/26/2015 R 3.1.2 running on a PC Win 7
library(RForcecom)

# load library to use sprintf and identity to get all names for loan objects
install.packages("gsubfn")
library(gsubfn)

username <- "username@place" # normal email/sflogin you will need your own :-)
password <- "PasswordHere" # you will need your own :-)
instanceURL <- "https://na14.salesforce.com/"
apiVersion <- "27.0"  ## left this default - did not check
session <- rforcecom.login(username, password, instanceURL, apiVersion)

####################################################################################################################

objectName <- "Account"
fields <- c("Id", "Name", "Phone")
ObjectTable <- rforcecom.retrieve(session, objectName, fields)

####################################################################################################################
# http://paintedriver.us/blog/2016/02/01/r-to-salesforce/

#TableName <- "Rate_Sheet__c"
TableName <- "Opportunity"

# getObjectDescription appears to error on custom tables, and is a known bug: https://github.com/hiratake55/RForcecom/issues/3
table.names <- rforcecom.getObjectDescription(session, TableName)
names <- toString( sprintf("%s", table.names$name))
table.query <- fn$identity( paste0( "SELECT $names FROM ",TableName) )
Table <- rforcecom.query(session, table.query)

# cast factors to characters
i <- sapply(Table, is.factor)
Table[i] <- lapply(Table[i], as.character)
rm(table.names, table.query)

####################################################################################################################
#Get a list of all Salesforce Objects
ObjectList<- as.data.frame( rforcecom.getObjectList(session) )

####################################################################################################################
#Get a description of a SF Object

#rforcecom.getObjectDescription(session, 'Policy__c')

####################################################################################################################
# USE SALESFORCE OBJECT QUERY LANGUAGE

#soqlQuery <- "SELECT fields FROM Policy__C"
#Policy <- rforcecom.query(session, soqlQuery)

####################################################################################################################
# USE THE RETRIEVE FUNCTION TO RETRIEVE ALL ROWS OF DEFINED FIELDS

#Policy <- rforcecom.retrieve(session, 'Policy__c', c("Id"))

####################################################################################################################
# Logout

rforcecom.logout(session)

