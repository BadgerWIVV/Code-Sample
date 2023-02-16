require(TTR)
require(ggplot2)
library(gridExtra)

datalocation= "C:/Location"
filelocation = "C:/Location2"
Data<-read.csv(file=datalocation)

t <- list()
rollLength = 25

# type 1= Allowed $, type 2= Quantity(Claim Lines)
for( type in 1:2){
    # proc 1= CPT, proc 2=DRG, proc 3=REV Code
    for( proc in 1:3) {
          #Top 10 Graphs
          for(i in 1:10) {
          p <- ggplot(data=Data, aes(x = time, y=APS, color= factor(TIN))) 
          p <- p + geom_line(data=Data, aes_string(y = colnames(Data)[i]))
          p <- p + ggtitle(colnames(Data)[i]) + xlab("Incurred Year-Month") + ylab("Allowed Amount Per Service Unit")
          print(p)
          ggsave( file = paste(colnames(Data)[i],".pdf",sep = "") , path = filelocation)
          assign(paste("p", i, sep = ""), p)
          t[[i]] <- p
          }
      }
}
do.call(grid.arrange,t)