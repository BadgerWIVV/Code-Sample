library(broom)
library(car)
library(dplyr)
library(lme4)
library(ggplot2)
library(reshape2)
library(RColorBrewer)
#library(yaml)
#library(knitr)
library(RODBC)

#RODBC connection
EDWquery<-" select * FROM [Database].[schema].[Table1]"
WHIOquery<-" select * FROM [Database].[schema].[Table2]"
channel <- odbcDriverConnect("driver=SQL Server;server=SERVER; database=Database")
EDWdata<-sqlQuery(channel,paste(EDWquery))
WHIOdata<- sqlQuery(channel,paste(WHIOquery))
odbcClose(channel)


#Grab the file
#===============
Procedure<-read.csv("C:/Location/FileName.csv")
WHIO<-read.csv("C:/Location/FileName2.csv")

#Use this to reduce ###'s data to the same timeframe as WHIO DMV 13
#Procedure<- Procedure[which(Procedure$Time>=29 & Procedure$Time<=55),]

#Grab the columns for FacilityTIN, Time, Billed_Per_Unit, MOD, Data_Source
Procedurestudy<-Procedure[,c("FacilityTIN","Time","Billed_Per_Unit","MOD","Data_Source")]
WHIOstudy<-WHIO[,c("FacilityTIN","Time","Billed_Per_Unit","MOD","Data_Source")]

      #Duplicate for Allowed Amounts
      Procedurestudy2<-Procedure[,c("FacilityTIN","Time","Allowed_Per_Unit","MOD","Data_Source")]
      WHIOstudy2<-WHIO[,c("FacilityTIN","Time","Resource_Per_Unit","MOD","Data_Source")]
      names(WHIOstudy2)<-names(Procedurestudy2)

gg_base_size <- 24

#Combine the two dataframes

Combined<-rbind(WHIOstudy,Procedurestudy)
ACombined<-rbind(WHIOstudy2,Procedurestudy2)

#Filter Time Frame
Combined1<-Combined[which(Combined$Time>=29 & Combined$Time<=55),]
ACombined1<-ACombined[which(ACombined$Time>=29 & ACombined$Time<=55),]

#Filter out modifiers
Combined2<-Combined1[which(Combined1$MOD=='59'|Combined1$MOD=='GO'|Combined1$MOD=='GP'|Combined1$MOD=='NULL'),]
ACombined2<-ACombined1[which(ACombined1$MOD=='59'|ACombined1$MOD=='GO'|ACombined1$MOD=='GP'|ACombined1$MOD=='NULL'),]

#Filter TINs
Combined3<-Combined2[which(Combined2$FacilityTIN=='Aurora Health Care Southern Lakes, Inc390806347'
                      |Combined2$FacilityTIN=='Aurora Health Care Metro, Inc390806181'),]
ACombined3<-ACombined2[which(ACombined2$FacilityTIN=='Aurora Health Care Southern Lakes, Inc390806347'
                           |ACombined2$FacilityTIN=='Aurora Health Care Metro, Inc390806181'),]


#Base Plot
base_plot <- ggplot(Combined3, aes(x = Time, y = Billed_Per_Unit,color=Data_Source)) +
  geom_point(position = position_jitter(0.2, 0.0),size = 2)  +  scale_x_continuous() 

Abase_plot <- ggplot(ACombined3, aes(x = Time, y = AMT_ALLOWED,color=Data_Source)) +
  geom_point(position = position_jitter(0.2, 0.0),size = 2) +scale_x_continuous() 


#Create a custom color scale
base_plot<-base_plot + scale_colour_manual(name = "Data Source",values = c("black","seagreen3"))
Abase_plot <-Abase_plot + scale_colour_manual(name = "Data Source",values = c("black","seagreen3"))


#facet_grid() and labels
#============
subj_base_plot <- base_plot + facet_grid(MOD~FacilityTIN, scales = "free") + ggtitle("Hospital Outpatient CPT 97140: WHIO v WEA")
subj_base_plot<-subj_base_plot + xlab("Time in Months: 29= Oct 2012, 55= Dec 2014")+ylab("Billed Per Service Unit")
subj_base_plot

Abase_plot <-Abase_plot + facet_grid(MOD~FacilityTIN, scales="free") + ggtitle("Hospital Outpatient CPT 97140: WHIO v WEA")
Abase_plot <-Abase_plot +xlab("Time in Months: 29= Oct 2012, 55= Dec 2014")+ylab("Resource Use Per Service Unit")


pdf("Aurora_97140.pdf", height=11, width=9)
print(subj_base_plot)
print(Abase_plot)
dev.off()
