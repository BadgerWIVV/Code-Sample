require(car)
require(broom)
require(dplyr)
require(lme4)
require(ggplot2)
require(reshape2)
require(RODBC)
require(stringr)

library(broom)
library(car)
library(dplyr)
library(lme4)
library(ggplot2)
library(reshape2)
library(RODBC)
library(stringr)

#RODBC connection to WHIOSQL

WHIOquery <- " select * FROM [Database].[schema].[Table]"
channel <- odbcDriverConnect("driver=SQL Server;server=SERVER; database=Database")
ProcedureBase<- sqlQuery(channel,paste(WHIOquery))
odbcClose(channel)

#Grab the file
#===============
Procedure<- ProcedureBase

#Standardize the names
names(Procedure) <- tolower(names(Procedure))

#Identify the top n highest variation CPTs
Procs<-as.list( dplyr::filter(Procedure
                     ,tos1=="Facility Outpatient"
                     ,time >=12
                     ,time <=35
                     ,str_length(proc_srv)==5) %>%
            group_by( proc_srv) %>%
              summarize(
                 mu = mean(billed_per_qty, na.rm=TRUE)
                 ,sigma = sd(billed_per_qty, na.rm=TRUE)
                 ,CoV = sd(billed_per_qty, na.rm=TRUE) / mean (billed_per_qty, na.rm=TRUE)
                ) %>% 
              arrange( desc(CoV)) %>% top_n(100, CoV) %>% select(proc_srv) )

#Set the gg plot base size
gg_base_size <- 24

#Commit the data to a dataframe
Procedurestudy<- dplyr::select(Procedure 
                               ,proc_srv 
                               ,proc_srv_desc
                               ,time 
                               ,billed_per_qty
                               ,tos1) %>% filter(time >=12
                                                ,time <=35
                                                ,str_length(proc_srv)==5
                                                #,tos1=="Professional Services"
                                                ,tos1=="Facility Outpatient"
                                                #,proc_srv != "82962" # There is an outlier in 82962 Professional that skews its results and all other graph y-axis
                                                ,proc_srv != "43239" # There is an outlier in 82962 Outpatient that skews its results and all other graph y-axis
                                                ,billed_per_qty > 0
                                                #,proc_srv %in% Procs
                                                ,proc_srv !=  "Q9967" 
                                                ,proc_srv !="85730"
                                                ,proc_srv !="97532"
                                                ,proc_srv =="G0151"
                                                |proc_srv =="74176"
                                                |proc_srv =="45380"
                                                |proc_srv =="45385"
                                                ,proc_srv !="82520"
                                                ,proc_srv !="99217"
                                                ,proc_srv !="H0020"
                                                ,proc_srv !="92250"
                                                ,proc_srv !="11100"
                                                ,proc_srv !="66984"
                                                )

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
  dplyr::select(proc_srv_desc, time, time_c, billed_per_qty)


#Base plot
#=========
theme_colors <- list(
  green = "#66c2a5" # colorbrewer.org
  ,orange = "#fc8d62" #
  ,blue = "#8da0cb"    #
  ,light_grey = "#f8f8f9"
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
  group_by(proc_srv_desc) %>%
  summarize(
    intercept = extract_lm_coef(billed_per_qty, time, 1),
    slope     = extract_lm_coef(billed_per_qty, time, 2)
  )


#Remove NA's
lm_effects<-lm_effects[complete.cases(lm_effects),]

#Order slopes of the LM
lm_effects <- lm_effects %>% 
  arrange(slope)

order_lm2<-length(lm_effects$proc_srv_desc):1
lm_effects<-cbind(lm_effects,order_lm2)

lm_effects <- lm_effects %>% 
  arrange(order_lm2)

decreasing_slope_lm <- lm_effects %>% 
  arrange(order_lm2) %>% .[["proc_srv_desc"]]

Procedure$proc_srv_desc <- factor(Procedure$proc_srv_desc, 
                    levels = decreasing_slope_lm)
##Grab top 30
top_lm<-head(lm_effects,6)

Procedure2<-Procedure[0]

for(i in 1:6){
Procedure3<-subset(Procedure, as.character(proc_srv_desc)==as.character(top_lm$proc_srv_desc[i]))
Procedure2<-bind_rows(Procedure2,Procedure3)
}

#Filter the NAs on Procedure2
Procedure2<-dplyr::filter(Procedure2, proc_srv_desc !="NA")

#Base Plot
base_plot <- ggplot(Procedure2, aes(x = time, y = billed_per_qty)) +
  geom_point(position = position_jitter(0, 0.0), 
             size = 6, color = theme_colors[["green"]])

base_plot <- base_plot +
  scale_x_continuous(breaks=cbind(12,35), labels=c("April '13","March '15")) +
  scale_y_continuous(breaks=cbind(0,2000, 4000, 6000), labels=c("$0","$2,000","$4,000","$6,000")) 

base_plot$layers[[1]] <- geom_point(aes(color = factor(proc_srv_desc), 
                                        size = 4))



#facet_wrap()
#============

subj_base_plot <- base_plot + facet_wrap("proc_srv_desc", ncol = 2)+
                            theme(strip.text.x = element_text(size=20, angle=0)
                                  ,strip.background = element_rect(colour="black", fill=light_grey)
                                  ,panel.background = element_rect(fill=NA, colour="black")
                                  ,panel.border = element_rect(colour= "black", fill = NA)
                                  )
                            

## Plot the top 30 LM, descending
PlotTopLM <- subj_base_plot + 
  geom_abline(data = top_lm
              ,size = 2
              ,mapping = aes(intercept = intercept
                             ,slope = slope
                             ,color = proc_srv_desc
                            )
              )

decreasing_slope_lm <- lm_effects %>% arrange(order_lm2) %>% .[["proc_srv_desc"]]

Procedure2$proc_srv <- factor(Procedure2$proc_srv_desc,levels = decreasing_slope_lm)

PlotTopLM <- PlotTopLM +labs(x=""
                             , y=""
                             ,y=element_blank()
                            )

PlotTopLM<- PlotTopLM + ggtitle(expression(atop("Outpatient Hospital Variation in Billed Per Quantity",atop(italic("Performed at the 10 Largest Systems in Wisconsin"), ""))))

PlotTopLM<-PlotTopLM + 

                            theme(axis.text.x = element_text(angle=0, hjust=0.5, vjust=1, colour= "black", size = 19, face = "bold")
                             ,axis.text.y = element_text(angle=0, hjust=1, vjust=0, colour= "black", size = 20, face = "bold")
                             ,plot.title = element_text(size = 30, face = "bold", colour = "black", vjust = -1)
                             ,axis.title.x = element_text(size = 30, angle = 00, face="bold")
                             ,axis.title.y = element_text(size = 30, angle = 90, face="bold")
                             
                             ,axis.title.y=element_blank()
                             ,axis.title.x=element_blank()
                             
                               #eliminates background, gridlines, and chart border
                             ,plot.background = element_blank()
                             ,panel.grid.major = element_blank()
                             ,panel.border = element_blank()
                             ,legend.position="none"
                            ) 

PlotTopLM

pdf("WHIO Outpatient Variation.pdf", height=14, width=25)
print(PlotTopLM)
dev.off()