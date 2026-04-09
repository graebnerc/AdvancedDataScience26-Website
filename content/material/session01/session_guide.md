# Session 1 — Instructor Guide

## Timeline

| Time | Block |
|------|-------|
| 15:00 – 16:00 | Concept intro (60 min) |
| 16:00 – 16:30 | Live demo (30 min) |
| 16:30 – 17:30 | Student exercise (60 min) |
| 17:30 – 18:00 | Debrief & Q&A (30 min) |

---

## Block 1 — Concept Intro (60 min)

Slides cover this block. Key moments to pause and ask:

- After the Preston curve slide: *"Why might life expectancy level off at high incomes?"*
- After log scale slide: *"Why not just use a normal axis?"*
- After the Quarto workflow slide: *"How do you currently share analysis with colleagues?"*

---

## Block 2 — Live Demo (30 min)

Build `demo.qmd` from scratch. Open RStudio. Do **not** open the finished file.

### Step 1 — YAML (≈ 8 min)

```yaml
---
title: "CO2 Emissions and Economic Development: A Global Perspective"
author: "Prof. Dr. Claudius Gräbner-Radkowitsch"
date: today
format:
  html:
    toc: true
    number-sections: true
    code-fold: true
    code-tools: true
  docx:
    toc: true
    number-sections: true
execute:
  warning: false
  message: false
bibliography: references.bib
---
```

- `date: today` — auto-updates on every render
- `code-fold` — keeps reports readable for non-coders
- `execute: warning/message: false` — cleaner output globally
- Two formats, one source file
- **Render now** — show empty but valid HTML

### Step 2 — Setup chunk (≈ 3 min)

```r
#| label: setup
#| include: false

library(tidyverse)
library(ggrepel)
library(modelsummary)
theme_set(theme_minimal(base_size = 13))
```

- `include: false` — runs silently; standard pattern for loading packages
- `theme_set()` — global theme once, not in every chunk

### Step 3 — Introduction + citation (≈ 5 min)

```markdown
## Introduction

Do richer countries pollute more? We explore the cross-country relationship
between economic output and CO2 emissions using World Bank data [@WDI2024].

## References
```

- Open `references.bib` — show what a BibTeX entry looks like
- Type `@` — show RStudio autocomplete for citation keys
- **Render** — point out in-text citation and reference list

### Step 4 — Load + prepare data (≈ 4 min)

```r
#| label: load-data

co2_data <- read_csv("data/wdi_co2_gdp_pop.csv")
```

```r
#| label: summarise-data

co2_avg <- co2_data |>
  group_by(country, iso2c, iso3c) |>
  summarise(
    across(c(co2_mt, gdp_ppp, pop, gdp_pc_ppp, co2_pc_t), mean),
    years_n = n(),
    .groups = "drop"
  ) |>
  filter(pop >= 1e6)
```

- Real data, not invented numbers — CSV already in the project folder
- `group_by` + `summarise` to average over years → smoother cross-country picture
- `filter(pop >= 1e6)` — drop micro-states

### Step 5 — Bubble chart (≈ 8 min)

```r
#| label: fig-bubble
#| fig-cap: "GDP per capita and CO2 emissions per capita (2020–2024 avg). Bubble size = population."

label_countries <- c("United States", "China", "India", "Germany",
                     "Brazil", "Nigeria", "Norway", "Saudi Arabia", "Indonesia")

ggplot(co2_avg, aes(x = gdp_pc_ppp, y = co2_pc_t, size = pop, label = country)) +
  geom_point(alpha = 0.5, colour = "#00395B") +
  geom_smooth(method = "lm", se = FALSE, color = "#69aacd", show.legend = FALSE) +
  geom_text_repel(
    data = co2_avg |> filter(country %in% label_countries),
    size = 3, colour = "#444444", max.overlaps = Inf, show.legend = FALSE
  ) +
  scale_x_log10(labels = scales::label_dollar(scale = 1/1000, suffix = "k")) +
  scale_y_log10(labels = scales::label_comma(suffix = " t")) +
  scale_size_continuous(range = c(1, 18),
                        labels = scales::label_comma(scale = 1/1e6, suffix = "M")) +
  labs(x = "GDP per capita (log, USD PPP)", y = "CO2 per capita (log, metric tons)",
       size = "Population",
       title = "Richer countries tend to emit more CO2 per person",
       subtitle = "But population size shapes total emissions — note China and India")
```

**Render first without log scales**, then add them and render again. Ask: *"Which version makes the relationship clearer?"*

- Both axes log-scaled — income and emissions span orders of magnitude
- `geom_text_repel` — avoids overlapping labels automatically
- Bubble size = population: China/India moderate per capita, enormous total
- Outliers to point out: Norway (high income, low emissions), Saudi Arabia (oil)
- Add `@fig-bubble` in prose — show it resolves to "Figure 1"

### Step 6 — Regression table (≈ 6 min)

```r
#| label: tbl-regression
#| tbl-cap: "OLS regression of log CO2 per capita on log GDP per capita."

co2_model <- co2_avg |>
  mutate(log_co2_pc = log(co2_pc_t),
         log_gdp_pc = log(gdp_pc_ppp))

model <- lm(log_co2_pc ~ log_gdp_pc, data = co2_model)

modelsummary(model, stars = TRUE, gof_map = c("nobs", "r.squared"),
             coef_rename = c("(Intercept)" = "Intercept",
                             "log_gdp_pc"  = "Log GDP per capita"))
```

- `modelsummary` → publication-ready table in one line
- Log-log model → coefficient is an *elasticity*
- Show inline R in prose:

```
...a 1% increase in GDP per capita is associated with a
`r round(coef(model)["log_gdp_pc"], 2)`% change in CO2 per capita.
```

- **Render** — the number updates if the model changes → reproducibility argument

### Step 7 — Word output (≈ 2 min)

- Render dropdown → **docx**
- Same source, different format — no copy-paste, no reformatting

> **If short on time:** skip Step 6 — it's in the exercise.

---

## Block 3 — Exercise (60 min)

Students work on `exercise.qmd` (GitHub Classroom assignment).

- Circulate; most common issues:
  - YAML indentation errors → spaces matter, no tabs
  - `references.bib` not found → path must be relative and file must be in the project root
  - `gapminder` not installed → `install.packages("gapminder")` (exercise uses gapminder, not WDI)
  - Cross-reference not resolving → label must start with `fig-` and match exactly
- Let fast finishers try the 1952 comparison or `facet_wrap(~ continent)`

---

## Block 4 — Debrief (30 min)

- Ask 2–3 students to share their rendered HTML
- Discussion questions:
  - *"Which country surprised you most in the bubble chart?"*
  - *"What does the elasticity coefficient actually mean for a company deciding where to operate?"*
  - *"When would you prefer Word output over HTML?"*
  - *"What would break reproducibility in your current workflow?"*
- Close with: *"The demo file is on the course website — download the source with the `<> Code` button and use it as a template."*
- Preview Session 2: same dataset, but now we ask *how much* does income predict CO2 — and how do we interpret that number precisely?
