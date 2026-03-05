# Instructor Notes: Live Demo — Session 1

These notes describe how to build `demo.qmd` live in class during the 40-minute
Quarto walkthrough block (16:20–17:00). The finished document is already in the
session folder; **do not open it during the demo**. Build it from scratch so
students see every decision being made.

---

## Before class

- Open RStudio with a clean project (or a Codespace)
- Have `references.bib` already in the project folder — you do not want to spend
  class time explaining BibTeX entry syntax
- Have the [Quarto HTML documentation](https://quarto.org/docs/output-formats/html-basics.html)
  open in a browser tab for reference
- Have the finished `demo.qmd` open in a *separate* window (not shared screen) as
  your safety net

---

## Step 1 — Create the file and explain the YAML (≈ 8 min)

**Action:** File → New File → Quarto Document. Delete the default content entirely.

Start typing the YAML live. Explain each field as you add it:

```yaml
---
title: "Income and Life Expectancy: A Global Perspective"
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
bibliography: references.bib
---
```

**Key talking points:**
- `date: today` — renders automatically, never needs manual updating
- `toc` and `number-sections` — what professional reports look like
- `code-fold: true` — keeps the report readable for non-coders; they can expand
  if curious
- Two output formats from one source file — this is the core value proposition
  of Quarto
- `bibliography` — just a path to a `.bib` file; we will use it later

**Render now** (even though the document is almost empty) so students see that
an empty YAML + no body still produces valid HTML. Point out the TOC, the
numbered-section placeholder, and the footer.

---

## Step 2 — Setup chunk (≈ 3 min)

Add the setup chunk immediately after the YAML:

```r
#| label: setup
#| include: false

library(tidyverse)
theme_set(theme_minimal(base_size = 13))
```

**Key talking points:**
- `include: false` — the chunk runs but produces nothing visible; this is the
  standard pattern for loading packages
- `theme_set()` — setting a global ggplot theme once avoids repeating it in
  every figure chunk
- A label on every chunk is good practice; it appears in error messages and in
  cross-references

---

## Step 3 — Write the Introduction with a citation (≈ 5 min)

Type the `## Introduction` section live. Keep the prose short — the point is
not the writing, it is the workflow.

When you reach the first citation, stop and explain:

- Open `references.bib` and show students what a BibTeX entry looks like
- Explain that `@Preston1975` in the text becomes a formatted citation in the
  output
- Show that RStudio autocompletes citation keys when you type `@`

Add the `## References` heading at the end of the document now, so students see
it is just a heading — Quarto fills in the list automatically.

**Render.** Point out the in-text citation and the reference list at the bottom.

---

## Step 4 — Build the data and the scatter plot (≈ 12 min)

This is the centrepiece of the demo. Create the inline dataset and the plot chunk:

```r
#| label: fig-scatter
#| fig-cap: "Life expectancy and GDP per capita across selected countries."

example_data <- tibble(
  country         = c("Nigeria", "India", "Brazil", "China",
                      "Mexico", "Poland", "Germany", "USA", "Norway"),
  gdp_per_capita  = c(5300, 6600, 14100, 16800,
                      19900, 31900, 53700, 63500, 67300),
  life_expectancy = c(54, 69, 75, 76, 75, 78, 81, 78, 82)
)

ggplot(example_data, aes(x = gdp_per_capita, y = life_expectancy)) +
  geom_point(colour = "#00395B", size = 3) +
  geom_text(aes(label = country), nudge_y = 0.6, size = 3.2) +
  labs(x = "GDP per capita (USD)", y = "Life expectancy (years)")
```

**Render. Then add the log scale:**

```r
scale_x_log10(labels = scales::label_dollar(scale = 1/1000, suffix = "k"))
```

**Render again.** This is the key pedagogical moment:

- Ask students: *"Which version makes the relationship clearer?"*
- Explain that log scale on x straightens a curved relationship — they will
  understand why formally in Sessions 2 and 3
- Point out `#| fig-cap` — the caption appears automatically, numbered

Also show cross-referencing: type `@fig-scatter` in the prose below the chunk
and render to show it resolves to "Figure 1".

---

## Step 5 — Add the regression table (≈ 8 min)

```r
#| label: tbl-regression
#| tbl-cap: "OLS regression of life expectancy on log GDP per capita."

library(modelsummary)

example_data <- example_data |>
  mutate(log_gdp = log(gdp_per_capita))

model <- lm(life_expectancy ~ log_gdp, data = example_data)

modelsummary(model, stars = TRUE, gof_map = c("nobs", "r.squared"))
```

**Key talking points:**
- `modelsummary` produces a publication-ready table in one line — no manual
  copying of numbers
- `gof_map` controls which fit statistics appear; here we show only n and R²
- The coefficient on `log_gdp` has a specific interpretation — previewing
  what Session 2 will cover in depth

Then add the inline R expression in the prose:

```
...increases by approximately `r round(coef(model)["log_gdp"] / 100, 2)` years...
```

Render and show that the number updates automatically if the model changes.
This is the core reproducibility argument.

---

## Step 6 — Render to Word (≈ 2 min)

Use the Render dropdown to switch to docx output. Point out:

- Same source, different format — no copy-pasting, no reformatting
- The `.docx` is less polished than HTML but fully functional
- This is how students will submit take-home tasks if they want a Word backup

---

## Timing buffer

If you run short on time, skip Step 6 (Word rendering) — it is covered in the
exercise. If you have extra time, show `code-fold: true` in action by expanding
a code chunk in the rendered HTML and discussing why hiding code by default is
good for non-technical readers.

---

## What to say at the end

> "The document you just saw me build is available on the course website as
> `demo.qmd`. Download the source using the `<> Code` button in the top-right
> corner. Use it as a template for your own reports — the YAML, the setup chunk,
> and the bibliography structure are all reusable."
