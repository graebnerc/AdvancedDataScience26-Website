# Add female back from the raw CPS file

here::i_am("content/material/session02/lecture_notes.r")
library(here)
library(tidyverse)
library(modelsummary)
library(flextable)

cps_raw <- read_csv(here("content/material/session02/data/morg-2014-emp.csv"))

cps <- cps_raw |>
  # Same filters as Task 1
  filter(occ2012 == 735) |>        # Market research analysts only
  filter(age >= 24, age <= 64) |>  # Working-age adults
  filter(uhours >= 20) |>          # At least part-time
  mutate(
    # Binary college indicator from Task 1 (keep for comparison)
    college = ifelse(grade92 >= 43, 1, 0),
    # Gender: CPS codes 1 = Male, 2 = Female
    female  = ifelse(sex == 2, 1, 0)
  ) |>
  select(earnwke, age, uhours, college, female, grade92) |>
  drop_na()

# Fit Model 3 from the take-home, now including gender

cps <- cps |> mutate(age_sq = age^2)

m3 <- lm(earnwke ~ age + age_sq + uhours + college, data = cps)

# New model: add gender
m4 <- lm(earnwke ~ age + age_sq + uhours + college + female, data = cps)

# Recode grade92 from binary to three education categories

cps <- cps |> 
  mutate(
    edu_cat = case_when(
      grade92 < 43 ~ "No degree",
      grade92 <= 44 ~ "Bachelor's",
      grade92 > 45 ~ "Graduate",
    ),
    edu_cat = factor(edu_cat, levels = c("No degree", "Bachelor's", "Graduate")),
    female = as.character(female)
  )

# Visualise: do male and female age-earnings profiles look parallel?
#   Add an age × female interaction

ggplot(data = cps, mapping = aes(x = age, earnwke, color = female, group = female)) +
  geom_point() +
  geom_smooth(method = "lm") +
  theme_bw()

# Compare all models in one clean modelsummary table

m4 <- lm(earnwke ~ age*female + age_sq + uhours + college, data = cps)
m4
