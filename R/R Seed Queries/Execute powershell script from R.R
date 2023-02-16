# ##########################################################################
# #Run the powershell script

# #https://stackoverflow.com/questions/31510432/running-a-powershell-script-from-r-using-system2-rather-than-system
# #https://stackoverflow.com/questions/10825069/using-shquote-with-r-on-windows
# 
system2("powershell", args=c("-file", shQuote("C:\\Location\\Embedded File\\Powershell File.ps1") ) )

