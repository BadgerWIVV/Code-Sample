library(ggplot2)

test_table<-read.csv(file="C:/Location/File.csv")
test_table <- as.data.frame(test_table)
attach(test_table)

#make a boxplot

p_out <- 
    ggplot(data=test_table,aes(x=MEG_DESC,y=Allowed)) + 
    geom_violin(data=test_table,aes(x=factor(MEG_DESC),y=Allowed, fill=factor(MEG_DESC)),outlier.shape=NA) +
    geom_boxplot(width=.1, fill="black", outlier.colour=NA) +
    stat_summary(fun.y=median, geom="point", fill="white", shape=21, size=2.5) +
    guides(fill=FALSE) +
    geom_point(data=test_table[test_table$Allowed > test_table$upper.limit | test_table$Allowed < test_table$lower.limit,], 
                                      aes(x=factor(MEG_DESC), y=Allowed, shape=factor(MEG_DESC))) +
    theme(strip.background = element_blank(), strip.text = element_blank()) +
    ggtitle("Distribution of Allowed Amounts for MEGs that Contain a Knee/Shoulder Arthroscopy") +
    xlab("MEG Description") +
    ylab("Allowed Amount") +
    facet_wrap(~MEG_DESC,nrow=3, ncol=6, scales="free")
  
p_out

pdf("2014 MEGs that Contain a Knee & Shoulder Arthroscopy.pdf", height=10.3, width=20)
print(p_out)
dev.off()


# FACETED HISTOGRAMS
# p_out <- 
#   ggplot(data=test_table, aes(x=Allowed)) +  
#   geom_histogram() +
#   ggtitle("Distribution of Allowed Amounts for MEGs that Contain a Knee/Shoulder Arthroscopy") +
#   xlab("MEG Description") +
#   ylab("Allowed Amount") +
#   facet_wrap(~MEG_DESC,nrow=3, ncol=6, scales="free")
# 
# p_out 