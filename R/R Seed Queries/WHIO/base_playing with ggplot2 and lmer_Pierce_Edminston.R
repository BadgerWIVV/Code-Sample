2-lmer-model-object
===================
  author: Pierce Edmiston
date: 1/21/2015
css: visualizing-lmer.css
```{r setup, echo = FALSE, warning = FALSE}
# --------------------------------------------------------------
library(broom)
library(car)
library(dplyr)
library(lme4)
library(ggplot2)
library(knitr)
library(reshape2)
library(yaml)

sleep<-read.csv(file.choose())

project_settings <- yaml.load_file("visualizing-lmer.yaml")

opts_chunk$set(
  fig.align = "center",
  fig.width = 7
  fig.height = 7
)

gg_base_size <- 24

names(sleep) <- tolower(names(sleep))
sleepstudy <- select(sleep, cpt, time, apu)
```
`github.com/pedmiston/visualizing-lmer`

Part 2
======
  * the lmer model object
* random intercepts and random slopes

More sleep data
===============
  ```{r, echo = -1}
# ?sleepstudy
library(lme4)
head(sleepstudy, n = 12)
( N <- length(unique(sleep$cpt)) )
```


Centering*
  ==========
  ```{r, echo = c(-4, -7)}
unique(sleep$time)
# use dplyr::data_frame to build incrementally
time_map <- dplyr::data_frame(  
  time = unique(sleep$time),
  time_c = time - median(time)
)
time_map

sleep <- left_join(sleepstudy, time_map)
sleepstudy <- sleep %>% 
  select(cpt, time, time_c, apu)
```
sleepstudy

Base plot
=========
  ```{r, echo = 3}
theme_colors <- list(
  green = "#66c2a5",  # colorbrewer.org
  orange = "#fc8d62", #
  blue = "#8da0cb"    #
)

base_plot <- ggplot(sleepstudy, aes(x = time_c, y = apu)) +
  geom_point(position = position_jitter(0.2, 0.0), 
             size = 4, color = theme_colors[["green"]])

base_plot <- base_plot +
  scale_x_continuous(
    "LOS" 
 #   ,breaks = los_map$days_c,
  #  labels = los_map$los
# 
) + 
 # scale_y_continuous(
    "Average Std Cost"
  #  ,breaks = seq(0, 50000, by = 2000)
  ) +
  theme_bw(base_size = 24)

base_plot
```

Ignoring subject (1)
====================
  ```{r}
simple_lm <- lm(apu ~ time_c, data = sleepstudy)
y_estimates <- predict(simple_lm, time_map, se.fit = TRUE)
estimates <- cbind(time_map, y_estimates) %>%
  select(time, time_c, apu = fit, se = se.fit)
```

Ignoring subject (2)
====================
  ```{r}
base_plot + geom_smooth(data = estimates,
                        mapping = aes(ymin = apu-se, ymax = apu+se),
                        stat = "identity", color = theme_colors[["blue"]], size = 2)
```

Repeated measures design
========================
  ```{r, echo = FALSE}
opts_chunk$set(
  fig.width = 10
)
```
```{r, echo = 1:2}
# color by subject; remove jitter
base_plot$layers[[1]] <- geom_point(aes(color = factor(cpt), 
                                    size = 4))
base_plot
```

facet_wrap()
============
  ```{r, echo = 1}
subj_base_plot <- base_plot + facet_wrap("cpt", ncol = 6)
subj_base_plot
```

Layer on the estimates
======================
  ```{r}
subj_base_plot + geom_smooth(data = estimates,
                             mapping = aes(ymin = apu-se, ymax = apu+se),
                             stat = "identity", color = "gray", size = 2)
```

Problems
========
  * many formal reasons why this is incorrect
* informal: not modeling the average subject

Method 1
========
  Fit an lm for every subject
```{r}
extract_lm_coef <- function(y, x, coef) {
  mod <- lm(y ~ x)
  coef(mod)[coef]
}

lm_effects <- sleepstudy %>% 
  group_by(cpt) %>%
  summarize(
    intercept = extract_lm_coef(apu, time_c, 1),
    slope     = extract_lm_coef(apu, time_c, 2)
  )

head(lm_effects, n = 6)
```

Is the average slope greater than 0?
====================================
  ```{r, echo = 1}
slopes_mod <- lm(slope ~ 1, data = lm_effects)
tidy(slopes_mod)
```

The easy button
===============
  ```{r}
lmList(apu ~ time | cpt, data = sleepstudy)
```

Method 2
========
  Think about it hierarchically
```{r, echo = 1}
lmer_mod <- lmer(apu ~ time_c + (time_c||cpt),
                 data = sleepstudy)
tidy(lmer_mod, effects = "fixed")
```

Compare
=======
  ```{r}
tidy(slopes_mod)
tidy(lmer_mod, effects = "fixed")
```

Whats in an lmer model object?
===============================
```{r}
summary(lmer_mod)
```

Fixed effects
=============
```{r}
fixef(lmer_mod)
tidy(lmer_mod, effects = "fixed")
```

Random effects
==============
```{r, echo = c(1,3)}
ranef(lmer_mod)
random_effects <- ranef(lmer_mod)[["cpt"]]
colMeans(random_effects)
```

coef() = fixef() + ranef()
==========================
```{r, echo = 1}
coef(lmer_mod)
```

Tidy them up
============
```{r}
tidy(lmer_mod, effects = "random")
```

A line for every subject
========================
```{r, echo = 1}
lmer_effects <- tidy(lmer_mod, effects = "random") %>%
dcast(level ~ term, value.var = "estimate") %>%
select(cpt = 1, intercept = 2, slope = 3)
lmer_effects
```

gg_magic
========
```{r, echo = 1}
subj_plot <- subj_base_plot + 
geom_abline(data = lmer_effects, size = 2,
mapping = aes(intercept = intercept, 
slope = slope, 
color = cpt))
subj_plot
```

Sort by slope
=============
```{r, echo = -4}
decreasing_slope <- lmer_effects %>% 
arrange(slope) %>% .[["cpt"]]
sleepstudy$cpt <- factor(sleepstudy$cpt, 
levels = decreasing_slope)
```

gg_update
=========
```{r, echo = 1}
subj_plot <- subj_plot %+% sleepstudy
subj_plot
```
###################################################################################################################################################
Comparing lmer to lmList (1)
============================
```{r, echo = FALSE}
tmp_plot <- subj_plot
tmp_plot$layers[[1]] <- geom_blank()
tmp_plot + geom_abline(data = lm_effects, 
lty = 2, size = 2,
mapping = aes(intercept = intercept, 
slope = slope, 
color = factor(cpt)))
```

Shrinkage
=========
```{r, echo = FALSE, fig.show = "hold", fig.width = project_settings[["opts_width"]] * 2/3, fig.height = project_settings[["opts_height"]] * 2/3}
compare <- merge(lm_effects, lmer_effects, by = "cpt", 
suffixes = c("_lmList", "_lmer"))

ggplot(compare, aes(x = intercept_lmer, y = intercept_lmList)) +
geom_point(size = 4) +
geom_abline(intercept = 0, slope = 1, lty = 2, size = 1) +
theme_bw(base_size = gg_base_size) +
ggtitle("Intercepts")

ggplot(compare, aes(x = slope_lmer, y = slope_lmList)) +
geom_point(size = 4) +
geom_abline(intercept = 0, slope = 1, lty = 2, size = 1) +
theme_bw(base_size = gg_base_size) +
ggtitle("Slopes")
```

predictSE()
===========
```{r, echo = -3}
library(AICcmodavg)
estimates <- predictSE(lmer_mod, time_map, se.fit = TRUE) %>%
cbind(time_map, .) %>% rename(reaction = fit, se = se.fit)
estimates
```

Final plot
==========
```{r}
subj_plot + geom_smooth(data = estimates,
mapping = aes(ymin = apu-se, ymax = apu+se), 
stat = "identity", color = "gray")
```