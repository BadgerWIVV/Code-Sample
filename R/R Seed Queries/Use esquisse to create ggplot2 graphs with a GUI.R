require( esquisse)

library(ggplot2)

ggplot(data = iris) +
  aes(x = Petal.Length, fill = Species, color = Sepal.Length, y = Petal.Length) +
  geom_violin(scale = "area", adjust = 1) +
  theme_minimal()
