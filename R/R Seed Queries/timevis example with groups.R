library(timevis)

BaseData <- data.frame(
  start = c(Sys.Date(), Sys.Date(), Sys.Date() + 1, Sys.Date() + 2),
  content = c("one", "two", "three", "four"),
  group = c(1, 2, 1, 2))

#I believe this might be a cross walk reference dimension table for each "group id"
GroupsForTimeVis <- data.frame(id = 1:2, content = c("G1", "G2"))

#Another crosswalk
SetGroupsForTimeVis <- data.frame(id = 1:2, content = c("Group 1", "Group 2"))


timevis(
  
  BaseData,
  #groups inside timevis() turn on the grouping function
  groups = GroupsForTimeVis
  #options = list(stack = TRUE)
) %>%
  #setGroups allows for possible renaming.
  setGroups(SetGroupsForTimeVis)




#########################################################################################
#Example 2
#I'm not sure I know how the subgroups are being used here

timedata <- data.frame(
  id = 1:6, 
  start = Sys.Date() + c(1, - 10, 4, 20, -10, 10),
  end = c(rep(as.Date(NA), 4), Sys.Date(), Sys.Date() + 20),
  group = c(1,1,1,2,2,2),
  content = c("event 1", "event 2", "event 2", "event 1", "range 1",     "range 1"),
  subgroup = c("1.1", "1.2", "1.2", "2.1", "2.2", "2.2")
)




groups <- data.frame(id = c(1,2), content = c("g1", "g2"))
timevis::timevis(data =timedata, groups = groups, options = list(stack = TRUE))



#########################################################################################
runExample()
