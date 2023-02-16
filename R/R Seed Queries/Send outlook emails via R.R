####RDCOMClient
#Does not work: This crashes on R version 3.6 >=

if(FALSE) {
  

#https://stackoverflow.com/questions/35509029/installation-error-with-rdcomclient-in-rstudio/51132513



#https://stackoverflow.com/questions/26811679/sending-email-in-r-via-outlook

#Install to send emails
#devtools::install_github('omegahat/RDCOMClient')

library(RDCOMClient)
## init com api
OutApp <- COMCreate("Outlook.Application")
## create an email 
outMail = OutApp$CreateItem(0)
## configure  email parameter 
outMail[["To"]] = "email@place"
outMail[["subject"]] = "Testing email"
outMail[["body"]] = "This is a test"
## send it                     
outMail$Send()

#outMail[["Attachments"]]$Add(path_to_attch_file)

#outMail[["SentOnBehalfOfName"]] = "yoursecondary@mail.com"

}

####sendmailR
#Does not work: SMTP server not allowed

if(FALSE) {
  
#https://stackoverflow.com/questions/26811679/sending-email-in-r-via-outlook

library(sendmailR)

#set working directory
#setwd("C:/workingdirectorypath")

#####send plain email

from <- "email@place"
to <- "email@place"
subject <- "Test Email"
body <- "This email is a test"                     
mailControl=list(smtpServer="serverinfo")

sendmail(from=from,to=to,subject=subject,msg=body,control=mailControl)

#####send same email with attachment

#needs full path if not in working directory
#attachmentPath <- "subfolder/log.txt"

#same as attachmentPath if using working directory
#attachmentName <- "log.txt"

#key part for attachments, put the body and the mime_part in a list for msg
#attachmentObject <- mime_part(x=attachmentPath,name=attachmentName)
#bodyWithAttachment <- list(body,attachmentObject)

#sendmail(from=from,to=to,subject=subject,msg=bodyWithAttachment,control=mailControl)
  
}