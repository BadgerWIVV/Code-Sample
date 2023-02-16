require(TTR)
require(ggplot2)
library(gridExtra)

set.seed(12345)
filelocation = "C:/Location"
values <- as.data.frame(matrix( rnorm(5*500,mean=0,sd=3), 500, 5))

t <- list()
rollLength = 25
for( i in 1:(ncol(values)))
{
  p <- ggplot(data=values, aes(x = index(values)) ) 
  p <- p + geom_line(data=values, aes_string(y = colnames(values)[i]))
  p <- p + geom_line(data = values, aes(x = index(values), y = runMax(values[,i], n = rollLength) ), colour = "blue", linetype = "longdash" )
  p <- p + geom_line(data = values, aes(x = index(values), y = runMin(values[,i], n = rollLength) ), colour = "blue", linetype = "longdash" )
  p <- p + ggtitle(colnames(values)[i]) + xlab("Date") + ylab("Pearson Correlation")
  print(p)
  ggsave( file = paste(colnames(values)[i],".pdf",sep = "") , path = filelocation)
  assign(paste("p", i, sep = ""), p)
  t[[i]] <- p
}

do.call(grid.arrange,t)