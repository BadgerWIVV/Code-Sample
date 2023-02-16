library(ggplot2)
library(reshape2)
library(gridExtra)
library(gtable)
library(plyr)



#TOP ETG Top 50 Systems by quantity
test_table<-read.csv(file="//filecs01/NewC/Location/Filename.csv")

test_table <- as.data.frame(test_table)

rows<-length(test_table[,1])
columns<-length(test_table[1,])
zzmatrix<-test_table
zzzmatrix<-matrix(rep(1,rows*columns),nrow=rows,ncol=columns)
details<-test_table[,1]



for(i in 1:(rows)){
  mean<-mean(as.matrix(test_table[i,(2:columns)]), na.rm=TRUE)
  sdev<-sd(as.matrix(test_table[i,(2:columns)]),na.rm=TRUE)
  for(j in 1:(columns)){
    zzzmatrix[i,j]=((test_table[i,j]-mean)/sdev)
    zzmatrix[i,j]<-zzzmatrix[i,j]
  }
}


row.names(zzmatrix) <- paste0("Code_",c(1:nrow(zzmatrix)))

#melt to an single array for plotting using boxplot
test_table_melt2 <- melt(zzmatrix)
test_table_melt2<-test_table_melt2[,2:3]

#Add Detail name to melted table
base<-as.data.frame(test_table[,1])
base2<-base
for (i in 1:(length(colnames(test_table))-2)) {
  base2<-rbind(base2,base)
}
test_table_melt<- cbind(test_table_melt2,base2)

#Add color element to each system in melted table
mod<-(rows*(columns-1))%%(rows*5)
times<-(rows*(columns-1)-mod)/(rows*5)
colorset<-as.data.frame(t(cbind(t(rep("red",rows)),t(rep("yellow",rows)),t(rep("green",rows)),t(rep("blue",rows)),t(rep("Violet",rows)))))
colorset2<-tail(colorset,mod)
for (i in 1:times) { 
  colorset2<-rbind(colorset2,colorset)
}
test_table_melt<-cbind(test_table_melt,colorset2)

#Add column names
colnames(test_table_melt)<-c('variable','value','ETGs','colorset')


#Remove NA's and Add Quartiles, Highs, and Lows
test_table_melt <- ddply(data.frame(na.omit(test_table_melt)), .(variable), mutate, Q1=quantile(value, 1/4), Q3=quantile(value, 3/4), IQR=Q3-Q1, upper.limit=Q3+1.5*IQR, lower.limit=Q1-1.5*IQR)
attach(test_table_melt)


#make a boxplot
plot_table <- function(df1,title1){
  p_out <- ggplot(data=df1,aes(x=variable,y=value)) +
    theme_bw() +
    geom_boxplot(data=test_table_melt,aes(x=factor(variable),y=value,fill=colorset),outlier.shape=NA) +
    geom_point(data=test_table_melt[test_table_melt$value > test_table_melt$upper.limit | 
                                      test_table_melt$value < test_table_melt$lower.limit,], 
               aes(x=factor(variable), y=value, shape=factor(ETGs))) +
    geom_hline(yintercept = 0,linetype = "dashed") +
    ggtitle(title1) +
    xlab("Systems") +
    ylab("Z scores") +
    theme(axis.text.x=element_text(ang=30,hjust=1,vjust=1))
  
  p_out
}

ptest <- plot_table(test_table_melt,paste("Z scores for top systems and top ETGs"))
ptest
