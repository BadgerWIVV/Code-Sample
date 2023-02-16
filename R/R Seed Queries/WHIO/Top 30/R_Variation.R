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

#Connection
#testquery<-"SELECT * FROM [Database].[schema].[Table]"
#The 12345 is the port number
#channel2 <- odbcDriverConnect("driver=SQL Server;server=SERVER,12345; database=DATABASE")
#testdata<-sqlQuery(channel2,paste(testquery))
#odbcClose(channel2)

#RODBC connection
EDWquery<-" select * FROM [Database].[schema].[Table]"
WHIOquery<-" select * FROM [Database].[schema].[Table2]"
channel <- odbcDriverConnect("driver=SQL Server;server=SERVER; database=Database")

EDWdata<-sqlQuery(channel,paste(EDWquery))
WHIOdata<- sqlQuery(channel,paste(WHIOquery))
odbcClose(channel)


#Grab the columns for FacilityTIN, Time, Billed_Per_Unit, MOD, Data_Source
EDWdata<-EDWdata[,c("FacilityTIN","Time","Billed_Per_Unit","MOD","Data_Source","CPT","System_Name","Allowed_Per_Unit")]
WHIOdata<-WHIOdata[,c("FacilityTIN","Time","Billed_Per_Unit","MOD","Data_Source","CPT","System_Name","Allowed_Per_Unit")]  

gg_base_size <- 24

#Combine the two dataframes
Combined<-rbind(WHIOdata,EDWdata)


#Filter Time Frame
Combined<-Combined[which(Combined$Time>=29 & Combined$Time<=55),]

#################################################################################
#Billed Per Unit
#################################################################################

#LOOP to print many
pdf("Billed_Per_Unit.pdf", height=11, width=9)


for(i in unique(Combined$CPT)){
  
  unique(Combined$System_Name)
  
  Combined$System_Name[4]

#Filter by CPT
Combined2<-Combined[which(Combined$CPT==i),]

for(j in unique(Combined2$System_Name)) {
#Filter by System
Combined3<-Combined2[which(Combined2$System_Name==j),]



#Base Plot
base_plot <- ggplot(Combined3, aes(x = Time, y = Billed_Per_Unit,color=Data_Source)) +
  geom_point(position = position_jitter(0.2, 0.0),size = 2)  +  scale_x_continuous() 


#Create a custom color scale
base_plot<-base_plot + scale_colour_manual(name = "Data Source",values = c("black","seagreen3"))


#facet_grid() and labels
#============
base_plot <- base_plot + facet_grid(MOD~FacilityTIN, scales = "free") + ggtitle(paste("Hospital Outpatient CPT ",i))
base_plot<-base_plot + xlab("Time in Months: 29= Oct 2012, 55= Dec 2014")+ylab("Billed Per Service Unit")
base_plot


print(base_plot)

}
}

dev.off()

#################################################################################
#Allowed Per Unit
#################################################################################

#LOOP to print many
pdf("Allowed_Per_Unit.pdf", height=11, width=9)

for(i in unique(Combined$CPT)){
  
  #Filter by CPT
  Combined2<-Combined[which(Combined$CPT==i),]
  
  for(j in unique(Combined2$System_Name)) {
    #Filter by System
    Combined3<-Combined2[which(Combined2$System_Name==j),]
    
    
    
    #Base Plot
    base_plot <- ggplot(Combined3, aes(x = Time, y = Allowed_Per_Unit,color=Data_Source)) +
      geom_point(position = position_jitter(0.2, 0.0),size = 2)  +  scale_x_continuous() 
    
    
    #Create a custom color scale
    base_plot<-base_plot + scale_colour_manual(name = "Data Source",values = c("black","seagreen3"))
    
    
    #facet_grid() and labels
    #============
    base_plot <- base_plot + facet_grid(MOD~FacilityTIN, scales = "free") + ggtitle(paste("Hospital Outpatient CPT ",i))
    base_plot<-base_plot + xlab("Time in Months: 29= Oct 2012, 55= Dec 2014")+ylab("Allowed Per Service Unit")
    base_plot
    
    
    print(base_plot)
    
  }
}

dev.off()

#################################################################################
#Aurora Health Sytem, CPT 97140, MOD GP TIN Aurora Metro
#################################################################################
Combined2<-Combined[which(Combined$System_Name==Combined$System_Name[4]),]
Combined2<-Combined2[which(Combined2$CPT==97140),]
Combined2<-Combined2[which(Combined2$MOD=="GP"),]
Combined2<-Combined2[which(Combined2$FacilityTIN=="Aurora Health Care Metro, Inc-390806181"),]

pdf("Billed_97140_base.pdf", height=11, width=9)

base_plot <- ggplot(Combined2, aes(x = Time, y = Billed_Per_Unit,color=Data_Source)) +
  geom_point(position = position_jitter(0.2, 0.0),size = 2)  +  scale_x_continuous() 


#Create a custom color scale
base_plot<-base_plot + scale_colour_manual(name = "Data Source",values = c("black","seagreen3"))


#facet_grid() and labels
#============
base_plot <- base_plot + facet_grid(MOD~FacilityTIN, scales = "free") + ggtitle(paste("Hospital Outpatient CPT 97140"))
base_plot<-base_plot + xlab("Time in Months: 29= Oct 2012, 55= Dec 2014")+ylab("Billed Per Service Unit")
#base_plot


print(base_plot)


dev.off()