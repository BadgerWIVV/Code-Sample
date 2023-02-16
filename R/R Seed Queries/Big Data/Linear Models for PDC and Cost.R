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
library(corrgram)
library(corrplot)
library(MASS)

#RODBC connection to WHIOSQL

WHIOquery <- " select * FROM [Database].[Schema].[Table]"
channel <- odbcDriverConnect("driver=SQL Server;server=SERVER; database=Database")
RAdataBASE<- sqlQuery(channel,paste(WHIOquery))
odbcClose(channel)

RAdata <- RAdataBASE

Model1 <- lm(RAdata$`Average PDC` ~ RAdata$`Depression` + RAdata$`SEX` + RAdata$AGE + RAdata$`Average MME` 
             + RAdata$`Percent of Days with Triple Adverse Drug Available` + RAdata$`Diabetes, Uncomplicated` + RAdata$`Diabetes, Complicated`
             + RAdata$`Charlson Comorbidity Index` + factor( RAdata$CONTRACT_TYPE ) + factor( RAdata$PRODUCT_DESC ) + factor( RAdata$`Product Level`)
             + PRISK + RRISK + RAdata$ConcurrentNonRAMedications + RAdata$`RA Total Billed` + RAdata$`RA Total Claim Lines`
             + RAdata$`Total Billed` + RAdata$`Total Claim Lines` +RAdata$CAT_STATUS + RAdata$CAT_STATUS_COST3 + factor( RAdata$COVERAGE_STATUS_DESC ) 
             ,data = RAdata)

summary(Model1)

StepModel <- stepAIC( Model1, direction = 'backward')

StepModel$anova

summary( StepModel)

Model2 <- lm(RAdata$`Average PDC` ~  RAdata$AGE 
             + RAdata$ConcurrentNonRAMedications + RAdata$`RA Total Billed`
             ,data = RAdata)

summary( Model2)

CostModel1 <- lm(RAdata$`Total Billed` ~  RAdata$`Depression` + RAdata$`SEX` + RAdata$AGE + RAdata$`Average MME` 
                 + RAdata$`Percent of Days with Triple Adverse Drug Available` + RAdata$`Diabetes, Uncomplicated` + RAdata$`Diabetes, Complicated`
                 + RAdata$`Charlson Comorbidity Index` + factor( RAdata$CONTRACT_TYPE ) + factor( RAdata$PRODUCT_DESC ) + factor( RAdata$`Product Level`)
                 + PRISK + RRISK + RAdata$ConcurrentNonRAMedications 
                 + RAdata$`Average PDC`   + factor( RAdata$COVERAGE_STATUS_DESC ) 
                 ,data = RAdata)

summary(CostModel1)

CostStepModel <- stepAIC( CostModel1, direction = 'backward')

CostStepModel$anova

summary( CostStepModel)

Model3 <- glm(RAdata$`Average PDC` ~ RAdata$`Liver Disease` +RAdata$`Valvular Disease` + RAdata$Paralysis + RAdata$Lymphoma + RAdata$Coagulopathy
              + RAdata$`Weight Loss` + RAdata$`Fluid And Electrolyte Disorders` + RAdata$Psychoses + factor(ifelse(is.na(RAdata$PCP_ASSIGN) = FALSE,1,0)) 
             ,data = RAdata, family="binomial")

summary(Model3)
