
library(ggplot2)
library(reshape2)
library(gridExtra)
library(gtable)
library(plyr)
library(RODBC)
library(nortest)
require(gWidgetstcltk)
options(guiToolkit="tcltk") 


Number_of_ETGs<-10
Number_of_Systems<-30
Quantity_Filter<-30

#Create a function that prompts users for a positive integer value only
readinteger <- function(text)
{ 
  n <- ginput(text)
  if((!grepl("^[0-9]+$",n))|(n==0))
  {
    return(readinteger(text))
  }
  
  return(as.integer(n))
}



#Recieve user input for query parameters
Number_of_ETGs<-readinteger("Please enter the number of ETGs you wish to include(5-30).
              The value you enter must be a positive integer.  ")

Number_of_Systems<- readinteger("Please enter the number of Systems you wish to include(5-70).
              The value you enter must be a positive integer.  ")

Quantity_Filter<-readinteger("Please enter the minimum number of episodes for each ETG (recommend 30+).
              The value you enter must be a positive integer.  ")


#Ensure numbers
Number_of_Systems<-as.numeric(Number_of_Systems)+1 #Add one to also include Wisconsin into the analysis
Number_of_ETGs<-as.numeric(Number_of_ETGs)
Quantity_Filter<-as.numeric(Quantity_Filter)

#State the Queries
Query_ETG_PEER <-paste("
DROP TABLE #ETG_PEER

    SELECT * 
      INTO #ETG_PEER
      FROM(
      
      SELECT A.ETG_ID,A.ETG_IMPACT_DESC, MP.PEER_DEF_DESC, MP.PEER_DEF_ID,COUNT(*) AS 'Count', ROW_NUMBER () OVER(PARTITION BY A.ETG_ID ORDER BY COUNT(*) DESC) AS 'Rank'
      FROM [WHIODB].[dbo].[QL_EPISODES] AS C
      LEFT JOIN [MAP_ETG] AS A ON C.ETG_ID=A.ETG_ID
      LEFT JOIN [dbo].[EPI_PROV] AS EP ON EP.EPISODE_ID=C.EPISODE_ID
      LEFT JOIN [dbo].[PROVINFO] AS PI ON PI.PROVIDER_ID=EP.PROVIDER_ID
      LEFT JOIN [dbo].[MAP_PROV_AFFIL] AS PA ON PI.AFFIL_ID=PA.AFFIL_ID
      LEFT JOIN [dbo].[MAP_PEER] AS MP ON MP.PEER_DEF_ID=EP.PEER_DEF_ID
      WHERE C.PRODUCT_ID IN ('COM: HMO$*', 'COM: IND$*', 'COM: OTH$*','COM: POS$*','COM: PPO$*') /*Commercial Only*/
        AND PA.PROV_AFFIL_LV2_ID IS NOT NULL /*Remove Nulls*/
        AND PI.STATE_N ='WI'  /*Wisconsin Only*/
        AND C.EPI_TYPE BETWEEN 0 AND 3 /*Complete Episodes*/
        AND LEFT(MP.PEER_DEF_DESC, 10) ='COMMERCIAL'
      GROUP BY A.ETG_ID,A.ETG_IMPACT_DESC, MP.PEER_DEF_DESC,MP.PEER_DEF_ID
    ) AS Q
    WHERE Rank=1
  ")

Query_Top_ETG <-paste("
DROP TABLE #Top_Etg

SELECT TOP ",Number_of_ETGs," 
Q.[ETG_ID]
,Q.[ETG_IMPACT_DESC]
,SUM(Q.COST1_TOT) AS 'Total Std Cost'
INTO #Top_Etg
FROM( SELECT DISTINCT A.ETG_ID,A.ETG_IMPACT_DESC, C.COST1_TOT
    FROM [WHIODB].[dbo].[QL_EPISODES] AS C
	  LEFT JOIN [MAP_ETG] AS A ON C.ETG_ID=A.ETG_ID
	  LEFT JOIN [dbo].[EPI_PROV] AS EP ON EP.EPISODE_ID=C.EPISODE_ID
	  LEFT JOIN [dbo].[PROVINFO] AS PI ON PI.PROVIDER_ID=EP.PROVIDER_ID
	  LEFT JOIN [dbo].[MAP_PROV_AFFIL] AS PA ON PI.AFFIL_ID=PA.AFFIL_ID
	  LEFT JOIN [dbo].[MAP_PEER] AS MP ON MP.PEER_DEF_ID=EP.PEER_DEF_ID
	  INNER JOIN #ETG_PEER AS CTE ON CTE.ETG_ID=C.ETG_ID AND CTE.PEER_DEF_ID=MP.PEER_DEF_ID
	  WHERE C.PRODUCT_ID IN ('COM: HMO$*', 'COM: IND$*', 'COM: OTH$*','COM: POS$*','COM: PPO$*') /*Commercial Only*/
	  AND PA.PROV_AFFIL_LV2_ID IS NOT NULL /*Remove Nulls*/
	  AND PI.STATE_N ='WI'  /*Wisconsin Only*/
	  AND C.EPI_TYPE BETWEEN 0 AND 3 /*Complete Episodes*/
	  AND C.ETG_ID <> 487
	  ) AS Q
GROUP BY Q.ETG_ID, Q.ETG_IMPACT_DESC
ORDER BY SUM(Q.COST1_TOT) DESC")

Query_Top_Episodes<-paste("
DROP TABLE #Top_Episodes

SELECT DISTINCT
ME.ETG_ID
,ME.ETG_IMPACT_DESC
,PA.PROV_AFFIL_LV2_DESC
,PA.PROV_AFFIL_LV2_ID
,E.COST1_TOT
,E.EPISODE_ID
INTO #Top_Episodes
FROM [dbo].[QL_EPISODES] AS E
LEFT JOIN [dbo].[EPI_PROV] AS EP ON E.EPISODE_ID=EP.EPISODE_ID
LEFT JOIN [dbo].[PROVINFO] AS PI ON PI.PROVIDER_ID=EP.PROVIDER_ID
LEFT JOIN [dbo].[MAP_PROV_AFFIL] AS PA ON PI.AFFIL_ID=PA.AFFIL_ID
LEFT JOIN [dbo].[MAP_ETG] AS ME ON E.ETG_ID=ME.ETG_ID
WHERE E.PRODUCT_ID IN ('COM: HMO$*', 'COM: IND$*', 'COM: OTH$*','COM: POS$*','COM: PPO$*')
AND E.EPI_TYPE BETWEEN 0 AND 3
AND E.ETG_ID IN (SELECT ETG_ID FROM #Top_Etg ) 
AND PA.PROV_AFFIL_LV2_ID IS NOT NULL /*Remove Nulls*/
AND PI.STATE_N ='WI'  /*Wisconsin Only*/

")

Query_Top_Systems<-paste("
DROP TABLE #Top_Systems                         

SELECT DISTINCT TOP ",Number_of_Systems," 
PROV_AFFIL_LV2_DESC AS 'System'
, COUNT(E.COST1_TOT) AS 'Quantity'
,PROV_AFFIL_LV2_ID
INTO #Top_Systems
FROM #Top_Episodes AS E
GROUP BY PROV_AFFIL_LV2_DESC,PROV_AFFIL_LV2_ID
ORDER BY COUNT(E.COST1_TOT) DESC

")

Query_Summary<-paste("
  SELECT ETG_ID, ETG_IMPACT_DESC, [System], Avg_Std_Cost, Quantity
  FROM
  	(SELECT DISTINCT
		ETG_ID,  ETG_IMPACT_DESC,  PROV_AFFIL_LV2_DESC AS 'System'
		, AVG(COST1_TOT) OVER(PARTITION BY ETG_ID, PROV_AFFIL_LV2_DESC) AS 'Avg_Std_Cost'
		, COUNT (EPISODE_ID) OVER(PARTITION BY ETG_ID,PROV_AFFIL_LV2_DESC) AS 'Quantity'
		FROM #Top_Episodes AS A
		WHERE PROV_AFFIL_LV2_ID IN (SELECT PROV_AFFIL_LV2_ID FROM #Top_Systems)
		) AS B
   WHERE Quantity >=",Quantity_Filter,"  /*Quantity Filter*/                     
                     
")


#Declare the channel connections
channel <- odbcDriverConnect("driver=SQL Server;server=SERVER; database=DATABASE")

#Create temp tables
sqlQuery(channel, paste(Query_ETG_PEER))

sqlQuery(channel,paste(Query_Top_ETG))

sqlQuery(channel,paste(Query_Top_Episodes))

sqlQuery(channel,paste(Query_Top_Systems))

#Fetch the summary
initdata2<-sqlQuery(channel,paste(Query_Summary))

#Close the channel
odbcClose(channel)

#Change the long table into a wide table to use for standarizing.
test_table<-dcast(initdata2,ETG_IMPACT_DESC~System,value.var="Avg_Std_Cost")

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

ptest <- plot_table(test_table_melt,paste("Z scores for top ",Number_of_Systems-1," systems (and Wisconsin)", "for top ",Number_of_ETGs,"ETGs", ", with a minimum of ",Quantity_Filter, "Episodes"))
ptest
