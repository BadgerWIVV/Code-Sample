##########################################################################
#REQUIREMENTS

library("readxl")

##########################################################################
#INPUTS

#URL may need to be in http and not https for the download to work.
URL <- "http://www.cdc.gov/drugoverdose/data-files/CDC_Oral_Morphine_Milligram_Equivalents_Sept_2017.xlsx" 

##########################################################################
#GET THE DATA

# Create a temporary file to store the file
tmp = tempfile(fileext = ".xlsx")

# Download the file to the temporary file
# Mode must be "wb" for non-flat files
download.file(URL, tmp, mode = "wb")

# Create the tbl_df for each of the spreadsheets
OpioidData <- read_excel(tmp, sheet = "Opioids")

#Destroy the temporary file
unlink(tmp)
