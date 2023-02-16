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
#sleep<-read.csv(file.choose())
sleep<-read.csv("C:/Location/Filename.csv")


gg_base_size <- 24

#Standardize the names and commit data to a dataframe
names(sleep) <- tolower(names(sleep))
sleepstudy <- select(sleep, cpt, time, apu)

#Preview the data
#===============
#head(sleepstudy, n = 12)
#( N <- length(unique(sleep$cpt)) )




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

#head(sleepstudy)

#Base plot
#=========
theme_colors <- list(
  green = "#66c2a5",  # colorbrewer.org
  orange = "#fc8d62", #
  blue = "#8da0cb"    #
)

base_plot <- ggplot(sleepstudy, aes(x = time, y = apu)) +
  geom_point(position = position_jitter(0.2, 0.0), 
             size = 4, color = theme_colors[["green"]])

base_plot <- base_plot +
  scale_x_continuous(
    #"time" 
    #   ,breaks = time_map$time_c,
    #  labels = time_map$time
    # 
  ) 
#+ 
  # scale_y_continuous(
  #"Average Price per Utilization"
#  ,breaks = seq(0, 50000, by = 2000)
#  )
#+ theme_bw(base_size = 24)

#base_plot



#Trend as an aggregate
#====================

simple_lm <- lm(apu ~ time, data = sleep)
y_estimates <- predict(simple_lm, time_map, se.fit = TRUE)
estimates <- cbind(time_map, y_estimates) %>%
 select(time, time_c, apu = fit, se = se.fit)


#Graph with aggregate trend
#====================
#base_plot + geom_smooth(data = estimates,
#                       mapping = aes(ymin = apu-se, ymax = apu+se),
 #                      stat = "identity", color = theme_colors[["blue"]], size = 2)


#Repeated measures design
#========================
#
#opts_chunk$set(
#  fig.width = 10
#)


# color by subject; remove jitter
base_plot$layers[[1]] <- geom_point(aes(color = factor(cpt), 
                                        size = 4))
#base_plot


#facet_wrap()
#============

subj_base_plot <- base_plot + facet_wrap("cpt", ncol = 6)
#subj_base_plot


#Layer on the aggregate trend line estimate
#======================

#subj_base_plot + geom_smooth(data = estimates,
  #                           mapping = aes(ymin = apu-se, ymax = apu+se),
  #                           stat = "identity", color = "gray", size = 2)



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

#head(lm_effects, n = 6)



#A line for every subject
#========================

#Create a LME for the entire data
lmer_mod <- lmer(apu ~ time + (time||cpt),
                 data = sleep)

#Create the lme for every subject
lmer_effects <- tidy(lmer_mod, effects = "random") %>%
  dcast(level ~ term, value.var = "estimate") %>%
  select(cpt = 1, intercept = 2, slope = 3)
#lmer_effects

######
#Remove NA's
lm_effects2<-lm_effects[complete.cases(lm_effects),]
lmer_effects2<-lmer_effects[complete.cases(lmer_effects),]

#Order slopes of the LME
lmer_effects2 <- lmer_effects2 %>% 
  arrange(slope)

order_lmer2<-length(lmer_effects2$cpt):1
lmer_effects2<-cbind(lmer_effects2,order_lmer2)

lmer_effects2 <- lmer_effects2 %>% 
  arrange(order_lmer2)

increasing_slope_lmer <- lmer_effects2 %>% 
  arrange(order_lmer2) %>% .[["cpt"]]

sleep$cpt <- factor(sleep$cpt, 
                    levels = increasing_slope_lmer)
#Order slopes of the LM
lm_effects2 <- lm_effects2 %>% 
  arrange(slope)

order_lm2<-length(lm_effects2$cpt):1
lm_effects2<-cbind(lm_effects2,order_lm2)

lm_effects2 <- lm_effects2 %>% 
  arrange(order_lm2)

increasing_slope_lm <- lm_effects2 %>% 
  arrange(order_lm2) %>% .[["cpt"]]

sleep$cpt <- factor(sleep$cpt, 
                    levels = increasing_slope_lm)
##Grab top 30
top_lm<-head(lm_effects2,30)
top_lmer<-head(lmer_effects2,30)

##Plot the top 30 LME, descending
PlotTopLMER <- subj_base_plot + 
  geom_abline(data = top_lmer, size = 2,
              mapping = aes(intercept = intercept, 
                            slope = slope, 
                            color = cpt))

increasing_slope_lmer <- lmer_effects2 %>% 
  arrange(order_lmer2) %>% .[["cpt"]]

sleep$cpt <- factor(sleep$cpt, 
                    levels = increasing_slope_lmer)

PlotTopLMER <- PlotTopLMER %+% sleep+xlab("Time in Months, 0= Jan 2010")+ylab("Average Allowed Per Utilization")
#PlotTopLMER

## Plot the top 30 LM, descending
PlotTopLM <- subj_base_plot + 
  geom_abline(data = top_lm, size = 2,
              mapping = aes(intercept = intercept, 
                            slope = slope, 
                            color = cpt))

increasing_slope_lm <- lm_effects2 %>% 
  arrange(order_lm2) %>% .[["cpt"]]

sleep$cpt <- factor(sleep$cpt, 
                    levels = increasing_slope_lm)

PlotTopLM <- PlotTopLM %+% sleep+xlab("Time in Months, 0= Jan 2010")+ylab("Average Allowed Per Utilization")
PlotTopLM

############


######Plot the LME model, All, ascending
#========

subj_plot <- subj_base_plot + 
  geom_abline(data = lmer_effects, size = 2,
              mapping = aes(intercept = intercept, 
                            slope = slope, 
                            color = cpt))


#Sort by slope
#=============

decreasing_slope <- lmer_effects %>% 
  arrange(slope) %>% .[["cpt"]]
sleep$cpt <- factor(sleep$cpt, 
                         levels = decreasing_slope)

#gg_update
#=========

subj_plot <- subj_plot %+% sleep+xlab("Time in Months, 0= Jan 2010")+ylab("Average Allowed Per Utilization")
#subj_plot

######Plot the linear model, All, ascending
#========

subj_plot_lm <- subj_base_plot + 
  geom_abline(data = lm_effects, size = 2,
              mapping = aes(intercept = intercept, 
                            slope = slope, 
                            color = cpt))


#Sort by slope for lm
#=============

decreasing_slope_lm <- lm_effects %>% 
  arrange(slope) %>% .[["cpt"]]
sleep$cpt <- factor(sleep$cpt, 
                    levels = decreasing_slope_lm)

#gg_update for lm
#=========

subj_plot_lm <- subj_plot %+% sleep+xlab("Time in Months, 0= Jan 2010")+ylab("Average Allowed Per Utilization")
#subj_plot_lm



