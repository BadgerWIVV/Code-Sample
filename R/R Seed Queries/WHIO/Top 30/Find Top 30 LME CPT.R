require(car)
require(broom)
require(dplyr)
require(lme4)
require(ggplot2)
require(reshape2)
require(RODBC)

library(broom)
library(car)
library(dplyr)
library(lme4)
library(ggplot2)
library(reshape2)
#library(yaml)
#library(knitr)
library(RODBC)
require(dplyr)

#query<-" select * FROM MAP_COUNTY"
#channel <- odbcDriverConnect("driver=SQL Server;server=SERVER; database=DATABASE")
#initdata2<- sqlQuery(channel,paste(query))
#odbcClose(channel)


#Grab the file
#===============
#Procedure<-read.csv(file.choose())
Procedure<-read.csv("C:/Location/Filename.csv")



gg_base_size <- 24

#Standardize the names and commit data to a dataframe
names(Procedure) <- tolower(names(Procedure))
Procedurestudy <- dplyr::select(Procedure,cpt, time, apu)


#Centering*
 # ==========
#unique(Procedure$time) 
# use dplyr::data_frame to build incrementally
time_map <- dplyr::data_frame(  
  time = unique(Procedure$time),
  time_c = time - median(time)
)

#time_map

Procedure <- left_join(Procedurestudy, time_map)
Procedurestudy <- Procedure %>% 
  dplyr::select(cpt, time, time_c, apu)


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
  group_by(cpt) %>%
  summarize(
    intercept = extract_lm_coef(apu, time, 1),
    slope     = extract_lm_coef(apu, time, 2)
  )


#Remove NA's
lm_effects<-lm_effects[complete.cases(lm_effects),]

#Order slopes of the LM
lm_effects <- lm_effects %>% 
  arrange(slope)

order_lm2<-length(lm_effects$cpt):1
lm_effects<-cbind(lm_effects,order_lm2)

lm_effects <- lm_effects %>% 
  arrange(order_lm2)

decreasing_slope_lm <- lm_effects %>% 
  arrange(order_lm2) %>% .[["cpt"]]

Procedure$cpt <- factor(Procedure$cpt, 
                    levels = decreasing_slope_lm)
##Grab top 30
top_lm<-head(lm_effects,30)

Procedure2<-Procedure[0]

for(i in 1:30){
Procedure3<-subset(Procedure, as.character(cpt)==as.character(top_lm$cpt[i]))
Procedure2<-bind_rows(Procedure2,Procedure3)
}

#Base Plot
base_plot <- ggplot(Procedure2, aes(x = time, y = apu)) +
  geom_point(position = position_jitter(0.2, 0.0), 
             size = 4, color = theme_colors[["green"]])

base_plot <- base_plot +
  scale_x_continuous() 

base_plot$layers[[1]] <- geom_point(aes(color = factor(cpt), 
                                        size = 4))



#facet_wrap()
#============

subj_base_plot <- base_plot + facet_wrap("cpt", ncol = 6)








## Plot the top 30 LM, descending
PlotTopLM <- subj_base_plot + 
  geom_abline(data = top_lm, size = 1,
              mapping = aes(intercept = intercept, 
                            slope = slope, 
                            color = cpt))

decreasing_slope_lm <- lm_effects %>% 
  arrange(order_lm2) %>% .[["cpt"]]

Procedure2$cpt <- factor(Procedure2$cpt, 
                    levels = decreasing_slope_lm)

PlotTopLM <- PlotTopLM %+% Procedure2+xlab("Time in Months, 0= Jan 2010")+ylab("Average Allowed Per Utilization")

PlotTopLM

