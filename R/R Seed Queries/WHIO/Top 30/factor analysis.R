Lines<-read.csv(file="C:/Location/Filename.csv")
Lines <- as.data.frame(Lines)
attach(Lines)

# col<-ncol(Lines)
# 
# dup<-as.data.frame(c(1:col))
# ChosenVariables<-as.data.frame(names(Lines))
# baseframe<-cbind(ChosenVariables,dup)
# names(baseframe)<-c("Name","Include_Flag")
# 
# 
# Include_function <-function(x) {
#   if(length(levels(factor(x)))>1) return(1)
#   else return(0)
# }
# 
# result<-sapply(baseframe[,1],Include_function)

# 
# 
# count=1
# for(i in unique(names(Lines))) {
#   if(length(levels(factor(Lines$i)))>1)  {
#       baseframe[count,2]<-1
#       count<<-count+1
#   }
#   else {
#       baseframe[count,2]<-0
#       count<<-count+1
#   }
#   
# }
 
CleanData<-as.data.frame(Lines[,1])
names(CleanData)<-"ScopeRow"
col<-ncol(Lines)
l2<-names(Lines)

for(i in col) 
{
if(length(levels(factor(Lines[,i])))>1) 
  { 
  l1<-names(CleanData)
  CleanData<-as.data.frame(cbind(CleanData[,],Lines[,i]))
  names(CleanData)<-c(l1,l2[i])
  CleanData<<-CleanData
  }
 CleanData<<-CleanData 
}









PredictorVariables<-names(Lines[,3:753])

Formula <- formula(paste("UNIT_Billed ~ ", 
                         paste("factor(",PredictorVariables,")", collapse=" + ")))

modelA<-lm(Formula, Lines)

summary(modelA)


#length(levels(factor(Lines[,233])))

