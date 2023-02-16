library(broom)
library(car)
library(dplyr)
library(lme4)
library(ggplot2)
library(reshape2)
#library(yaml)
#library(knitr)

#Grab the file
#===============
sleep<-read.csv(file.choose())



gg_base_size <- 24

#Standardize the names and commit data to a dataframe
names(sleep) <- tolower(names(sleep))
sleepstudy <- select(sleep, cpt, time, apu)


#Centering*
 # ==========
#unique(sleep$time) 
# use dplyr::data_frame to build incrementally
time_map <- dplyr::data_frame(  
  time = unique(sleep$time),
  time_c = time - median(time)
)

#time_map

sleep <- left_join(sleepstudy, time_map)
sleepstudy <- sleep %>% 
  select(cpt, time, time_c, apu)


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
lm_effects <- sleep %>% 
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

sleep$cpt <- factor(sleep$cpt, 
                    levels = decreasing_slope_lm)
##Grab top 30
top_lm<-head(lm_effects,30)

sleep2<-sleep[0]

for(i in 1:30){
sleep3<-subset(sleep, as.character(cpt)==as.character(top_lm$cpt[i]))
sleep2<-bind_rows(sleep2,sleep3)
}

#Base Plot
base <- ggplot(sleep2,aes(x=apu, fill=cut))
hist<- base + geom_histogram(aes(fill=..count..)) +geom_density()+
  scale_fill_gradient("Count", low="red", high="green")+
  ylab("Count")+
  xlab("Average Price")




#base_plot$layers[[1]] <- geom_point(aes(color = factor(cpt))



#facet_wrap()
#============

subj_base <- hist+ facet_wrap("cpt", ncol = 6)

subj_base






## Plot the top 30 LM, descending
PlotTopLM <- subj_base + 
  geom_abline(data = top_lm, size = 1,
              mapping = aes(intercept = intercept, 
                            slope = slope, 
                            color = cpt))

decreasing_slope_lm <- lm_effects %>% 
  arrange(order_lm2) %>% .[["cpt"]]

sleep2$cpt <- factor(sleep2$cpt, 
                    levels = decreasing_slope_lm)

PlotTopLM <- PlotTopLM %+% sleep2+xlab("Time in Months, 0= Jan 2010")+ylab("Average Allowed Per Utilization")

PlotTopLM

