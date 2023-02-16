require("DiagrammeR")



#https://towardsdatascience.com/r-visualizations-flow-charts-in-r-4cfa7f783872

#https://rich-iannone.github.io/DiagrammeR/graphviz_and_mermaid.html

#https://stackoverflow.com/questions/49139028/change-subgraph-cluster-shape-to-rounded-rectangle

grViz( diagram = "digraph flowchart {
       node [fontname = arial, shape = oval, color = grey, style = filled]
       tab1 [label = '@@1']
       tab2 [label = '@@2']
       tab3 [label = '@@3']
       
       tab1 -> tab2 -> tab3;
}
 
  [1]: 'Learning Data Science'
  [2]: 'Industry vs Technical Knowledge'
  [3]: 'Statistics vs Mathematics Knowledge'
       
  ")





grViz( diagram = "digraph flowchart 
    
  {
  #Define node aesthetics
  node [fontname = Arial, shape = oval, color = Lavender, style = filled, fontcolor = Black]
  
  #Define tables
  tab1 [label = '@@1']
  tab2 [label = '@@2']
  tab3 [label = '@@3']
  tab4 [label = '@@4']
       
  #Set up Node Layout
  tab1 -> tab2 
  tab2 -> tab3
  tab2 -> tab4;
  }
 
  #Define Table text
  [1]: 'Learning Data Science'
  [2]: 'Industry vs Technical Knowledge'
  [3]: 'Python/R'
  [4]: 'Domain Experience'
       
")




grViz( diagram = "digraph flowchart 
    
  {
  #Define node aesthetics
  node [fontname = Arial, shape = oval, color = DeepSkyBlue, style = filled, fontcolor = White]
  
  #Define tables
  tab1 [label = '@@1']
  tab2 [label = '@@2']
  tab3 [label = '@@3']
  tab4 [label = '@@4']
       
  #Set up Node Layout
  tab1 -> tab2 
  tab2 -> tab3
  tab2 -> tab4
  tab1 -> tab4;
  }
 
  #Define Table text
  [1]: 'Learning Data Science'
  [2]: 'Industry vs Technical Knowledge'
  [3]: 'Python/R'
  [4]: 'Domain Experience'
       
")



grViz( diagram = "digraph flowchart 
    
  {
  #Define node aesthetics
  node [fontname = Arial, shape = rectangle, color = DeepSkyBlue, style = 'rounded,filled', fontcolor = White]
  
  #Define tables
  tab1 [label = '@@1']
  tab2 [label = '@@2']
  tab3 [label = '@@3']
  tab4 [label = '@@4']
       
  #Set up Node Layout
  tab1 -> tab2 
  tab2 -> tab3
  tab2 -> tab4
  tab1 -> tab4;
  }
 
  #Define Table text
  [1]: 'Learning Data Science'
  [2]: 'Industry vs Technical Knowledge'
  [3]: 'Python/R'
  [4]: 'Domain Experience'
       
")
