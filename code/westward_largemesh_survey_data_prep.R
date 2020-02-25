# notes ----
## Data preparation and test for VAST training
## Westward Region large-mesh Tanner crab survey
## author: Tyler Jackson
## last updated 2020/2/24
## data source: Kally Spalinger, Ric Shepard

# load ----

library(tidyverse)
library(VAST)

# data ----

## haul data
haul <- read_csv("./data/trawl_all_haul_summary.csv")

## crab catch data
catch <- read_csv("./data/trawl_all_crab_catch_by_station.csv")

# data mgmt ----

## manipulate raw data
haul %>%
  ## pull year from survey name
  mutate(year = as.numeric(substring(survey_name, 5, 8))) %>%
  ## remove poor performance tows (they re-tow when needed)
  filter(perform <= 4) %>%
  ## rename fields
  rename(distance_km = numeric,
         duration_min = duration,
         date = to_char, 
         depth_fa = depth_avg,
         start_lat = mapinfo_lat,
         start_lon = mapinfo_lon,
         end_lat = mapinfo_lat_1,
         end_lon = mapinfo_lon_1) %>%
  select(year, tow, date, station, haul, tsect, start_lat, start_lon, end_lat, end_lon, 
         distance_km, duration_min, depth_fa, bottom_temp) -> haul_rev

##  select counts of mature males and legal males from catch
catch %>%
  select(tow, tot_mature, tot_legal) -> catch_rev

## create two data sets: 
### 1) 1988 to 2019 (location is start lat and lon, temperature data is incomplete)
### 2) 1999 to 2018 (location is mid point of tow, tempature data is complete)

### 1)
haul_rev  %>%
  select(-end_lat, -end_lon) %>%
  mutate(vessel = "Resolution", 
         net_width_km = 0.0122, 
         area_swept_km2 = distance_km * net_width_km) %>%
  left_join(catch_rev, by = "tow") -> tmp_1988_2019
write_csv(tmp_1988_2019, "./data/westward_GOA_tanner_crab_1988_2019.csv")

### 2)
haul_rev  %>%
  filter(year %in% 1999:2018) %>%
  mutate(lat = (start_lat + end_lat) / 2,
         lon = (start_lon + end_lon) / 2,
         vessel = "Resolution", 
         net_width_km = 0.0122, 
         area_swept_km2 = distance_km * net_width_km) %>%
  select(-start_lat, -start_lon, -end_lat, -end_lon) %>%
  left_join(catch_rev, by = "tow") -> tmp_1999_2018
write_csv(tmp_1988_2019, "./data/westward_GOA_tanner_crab_1999_2018.csv")


# VAST test ----

## create directory to populate
dir.create("./VAST_test")

## temporarily switch wd to new directory
setwd("./VAST_test")

## list of sampling inputs
tmp <- list(sampling_data = as.data.frame(tmp_1999_2018),
            Region = "gulf_of_alaska",
            strata.limits = data.frame(STRATA = "All_areas"))

## Make settings (turning off bias.correct to save time for example)
settings <- make_settings(n_x = 100, Region = tmp$Region, purpose = "index", 
                          bias.correct = FALSE)
## Run model
fit <- fit_model("settings" = settings, 
                "Lat_i" = tmp$sampling_data[,'lat'], 
                "Lon_i" = tmp$sampling_data[,'lon'], 
                "t_i" = tmp$sampling_data[,'year'], 
                "c_i" = rep(0,nrow(tmp$sampling_data)), 
                "b_i" = tmp$sampling_data[,'tot_mature'], 
                "a_i" = tmp$sampling_data[,'area_swept_km2'], 
                "v_i" = tmp$sampling_data[,'vessel'])
## Plot results
plot(fit)

## revert back to root directory
setwd("..")
