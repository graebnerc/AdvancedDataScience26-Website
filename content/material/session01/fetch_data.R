# fetch_data.R
# Downloads CO2 emissions, GDP (PPP), and population data from the World Bank
# using the WDI package and saves a clean CSV to data/wdi_co2_gdp_pop.csv.

here::i_am("content/material/session01/fetch_data.R")
library(here)
library(WDI)
library(tidyverse)

# ── Fetch indicators ──────────────────────────────────────────────────────────
# EN.GHG.CO2.MT.CE.AR5 : Total GHG/CO2 emissions, Mt CO2 equivalent (AR5)
# NY.GDP.MKTP.PP.CD    : GDP, PPP (current international $)
# SP.POP.TOTL          : Population, total
raw <- WDI(
  indicator = c(
    co2_mt   = "EN.GHG.CO2.MT.CE.AR5",
    gdp_ppp  = "NY.GDP.MKTP.PP.CD",
    pop      = "SP.POP.TOTL"
  ),
  start = 2020,
  end   = 2024,
  extra = TRUE   # adds region, income group, etc. — needed to drop aggregates
)

# ── Clean ─────────────────────────────────────────────────────────────────────
co2_data <- raw |>
  # Remove World Bank regional/income aggregates (they have region == "Aggregates")
  filter(region != "Aggregates") |>
  # Keep only the columns needed for the demo
  select(country, iso2c, iso3c, year, co2_mt, gdp_ppp, pop) |>
  # Drop any country-year observation with a missing value in any indicator
  drop_na(co2_mt, gdp_ppp, pop) |>
  # Derive per-capita variables
  mutate(
    gdp_pc_ppp  = gdp_ppp / pop,          # GDP per capita (PPP, USD)
    co2_pc_t    = co2_mt * 1e6 / pop      # CO2 per capita (metric tons / person)
  ) |>
  arrange(country, year)

# ── Save ──────────────────────────────────────────────────────────────────────
write_csv(co2_data, here("content/material/session01/data/wdi_co2_gdp_pop.csv"))

message("Saved ", nrow(co2_data), " country-year rows to data/wdi_co2_gdp_pop.csv")
message("Countries: ", n_distinct(co2_data$country))
message("Years covered: ", paste(sort(unique(co2_data$year)), collapse = ", "))
