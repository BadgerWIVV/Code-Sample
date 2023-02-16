library(broom)
library(car)
library(dplyr)
library(lme4)
library(ggplot2)
library(reshape2)
#library(yaml)
#library(knitr)
library(RODBC)

#query<-" select * FROM Database.SCHEMA.TABLE"
#RODBC connection
#channel <- odbcDriverConnect("driver=SQL Server;server=SERVER; database=DATABASE")
#initdata2<- sqlQuery(channel,paste(query))
#odbcClose(channel)


#Grab the file
#===============
Procedurestudy<-read.csv("C:/Location/Filename.csv")
WHIO<-read.csv("C:/Location/Filename2.csv")
#Procedurestudy[,3]<-Procedurestudy[,3]*100


gg_base_size <- 24

#Standardize the names and commit data to a dataframe
#names(Procedure) <- tolower(names(Procedure))
#Procedurestudy <- select(Procedure, FacilityTIN, time, Billed_Per_Unit)


#Centering*
# ==========
#unique(Procedure$time) 
# use dplyr::data_frame to build incrementally
#time_map <- dplyr::data_frame(  
#  time = unique(Procedure$time),
#  time_c = time - median(time)
#)

#time_map

#Procedure <- left_join(Procedurestudy, time_map)
Procedurestudy <- Procedure %>% 
  select(FacilityTIN, Time, Billed_Per_Unit)

WHIOstudy<-WHIO%>% select(FacilityTIN, Time, Billed_Per_Unit)
WHIOmode<-WHIO%>% select(FacilityTIN,Time,Mode_for_TIN_for_Year)

#Base plot
#=========
theme_colors <- list(
  green = "#66c2a5",  # colorbrewer.org
  orange = "#fc8d62", #
  blue = "#8da0cb"    #
)




#  Fit a linear model for every subject
#  ========

#Function to extract the coeffecients
extract_lm_coef <- function(y, x, coef) {
  mod <- lm(y ~ x)
  coef(mod)[coef]
}

#Store the coeffecients as a dataframe called lm_effects
lm_effects <- Procedure %>% 
  group_by(FacilityTIN) %>%
  summarize(
    intercept = extract_lm_coef(Billed_Per_Unit, Time, 1),
    slope     = extract_lm_coef(Billed_Per_Unit, Time, 2)
  )

lm_effectsWHIO <- WHIO %>% 
  group_by(FacilityTIN) %>%
  summarize(
    intercept = extract_lm_coef(Billed_Per_Unit, Time, 1),
    slope     = extract_lm_coef(Billed_Per_Unit, Time, 2)
  )
#Remove NA's
lm_effects<-lm_effects[complete.cases(lm_effects),]
lm_effectsWHIO<-lm_effectsWHIO[complete.cases(lm_effectsWHIO),]
#Order slopes of the LM
lm_effects <- lm_effects %>% 
  arrange(slope)

order_lm2<-length(lm_effects$FacilityTIN):1
lm_effects<-cbind(lm_effects,order_lm2)

lm_effects <- lm_effects %>% 
  arrange(order_lm2)

decreasing_slope_lm <- lm_effects %>% 
  arrange(order_lm2) %>% .[["FacilityTIN"]]

Procedure$FacilityTIN <- factor(Procedure$FacilityTIN, 
                        levels = decreasing_slope_lm)

lm_effectsWHIO <- lm_effectsWHIO %>% 
  arrange(slope)

order_lm2<-length(lm_effectsWHIO$FacilityTIN):1
lm_effectsWHIO<-cbind(lm_effectsWHIO,order_lm2)

lm_effectsWHIO <- lm_effectsWHIO %>% 
  arrange(order_lm2)

decreasing_slope_lm <- lm_effectsWHIO %>% 
  arrange(order_lm2) %>% .[["FacilityTIN"]]

WHIO$FacilityTIN <- factor(WHIO$FacilityTIN, 
                                levels = decreasing_slope_lm)
##Grab top 30
top_lm<-head(lm_effects,30)
top_lmWHIO<-head(lm_effectsWHIO,30)
Procedure2<-Procedure[0]
WHIO2<-WHIO[0]
for(i in 1:30){
  Procedure3<-subset(Procedure, as.character(FacilityTIN)==as.character(top_lm$FacilityTIN[i]))
  Procedure2<-bind_rows(Procedure2,Procedure3)
  WHIO3<-subset(WHIO, as.character(FacilityTIN)==as.character(top_lmWHIO$FacilityTIN[i]))
  WHIO2<-bind_rows(WHIO2,WHIO3)
}

#Base Plot
base_plot <- ggplot(Procedure2, aes(x = Time, y = Billed_Per_Unit)) +
  geom_point(position = position_jitter(0.2, 0.0), 
             size = 4, color = theme_colors[["green"]])

base_plot <- base_plot +
  scale_x_continuous() 

#base_plot<-base_plot +geom_point() + geom_point(data=WHIO2, x=WHIO2$Time, y=WHIO2$Billed_Per_Unit)


base_plot$layers[[1]] <- geom_point(aes(color = factor(FacilityTIN), 
                                        size = 4))


base_plotWHIO <- ggplot(WHIO2, aes(x = Time, y = Billed_Per_Unit)) +
  geom_point(position = position_jitter(0.2, 0.0), 
             size = 4, color = theme_colors[["grey"]])

base_plotWHIO <- base_plotWHIO +
  scale_x_continuous() 

base_plotWHIO$layers[[1]] <- geom_point(aes(color = factor(FacilityTIN), 
                                        size = 4))


#facet_wrap()
#============

subj_base_plot <- base_plot + facet_wrap("FacilityTIN", ncol = 6)

WHIO_base_plot<-base_plotWHIO + facet_wrap("FacilityTIN",ncol=6)






## Plot the top 30 LM, descending
PlotTopLM <- subj_base_plot + 
  geom_abline(data = top_lm, size = 1,
              mapping = aes(intercept = intercept, 
                            slope = slope, 
                            color = FacilityTIN))

decreasing_slope_lm <- lm_effects %>% 
  arrange(order_lm2) %>% .[["FacilityTIN"]]

Procedure2$FacilityTIN <- factor(Procedure2$FacilityTIN, 
                         levels = decreasing_slope_lm)

PlotTopLM <- PlotTopLM %+% Procedure2+xlab("Time in Months, 1 = June 2010")+ylab("Billed Per Unit")
PlotTopLM <- PlotTopLM + ggtitle("Aurora Unit Charges for CPT 97140")
PlotTopLM


PlotTopLMWHIO <- WHIO_base_plot + 
  geom_abline(data = top_lmWHIO, size = 1,
              mapping = aes(intercept = intercept, 
                            slope = slope, 
                            color = FacilityTIN))

decreasing_slope_lmWHIO <- lm_effectsWHIO %>% 
  arrange(order_lm2) %>% .[["FacilityTIN"]]

WHIO2$FacilityTIN <- factor(WHIO2$FacilityTIN, 
                                 levels = decreasing_slope_lmWHIO)

PlotTopLMWHIO <- PlotTopLMWHIO %+% WHIO2+xlab("Time in Months, 1 = June 2010")+ylab("Billed Per Unit")
PlotTopLMWHIO <- PlotTopLMWHIO + ggtitle("Aurora Unit Charges for CPT 97140")
PlotTopLMWHIO
