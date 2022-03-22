library(tidycensus)
library(tidyverse)
options(tigris_use_cache = TRUE)
census_api_key("0fb1cd3d58bf3205c4d8b4d673a4c186e57ea875", install = TRUE)

v17 <- load_variables(2017, "acs5", cache = TRUE)

View(v17)


Atlantic <- get_acs(state = "NJ", county = "Atlantic", geography = "state", 
                     variables = "B0000_001", geometry = TRUE)


Hunterdon <- get_acs(state = "NJ", county = "Hunterdon", geography = "county subdivision", 
                  variables = "B00001_001", geometry = TRUE)


First_Year <- 2019
Second_Year <- 2020


Hunterdon_0 <- get_acs(state = "NJ", county="Hunterdon", geography = "county subdivision", 
                     variables = "B01003_001", geometry = TRUE, year=First_Year)
Hunterdon_1 <- get_acs(state = "NJ", county="Hunterdon", geography = "county subdivision", 
                       variables = "B01003_001", geometry = TRUE, year=Second_Year)
Hunterdon_combined <- left_join(Hunterdon_0, Hunterdon_1, by=c("NAME","GEOID"))


NJ_POP_10<-get_decennial(
                          state = "NJ",
                          geography = "state",
                          variables=c(pop00="P001001"),
                          output="wide",
                          year=2010
                          )

NJ_POP_20<-get_decennial(
                          state="NJ",
                          geography = "state",
                          variables=c(pop10="P001001"),
                          output="wide",
                          year=2020
                          )
state_pop<-left_join(state_pop00, state_pop10, by=c("NAME","GEOID"))


vt %>%
  mutate(NAME = gsub(" County, NJ", "", NAME)) %>%
  ggplot(aes(x = estimate, y = reorder(NAME, estimate))) +
  geom_errorbarh(aes(xmin = estimate - moe, xmax = estimate + moe)) +
  geom_point(color = "red", size = 3) +
  labs(title = "Household income by county in Vermont",
       subtitle = "2014-2018 American Community Survey",
       y = "",
       x = "ACS estimate (bars represent margin of error)")

# head(Hunterdon)

# crs = 26911 is appropriate for Orange County, but may not be appropriate for your area.
# Use the crsuggest package to identify an appropriate CRS for your area.
Hunterdon <- Hunterdon %>%
  ggplot(aes(fill = estimate)) + 
  geom_sf(color = NA) + 
  coord_sf(crs = 26911) + 
  scale_fill_viridis_c(labels = scales::dollar) 
Hunterdon

Atlantic <- Atlantic %>%
  ggplot(aes(fill = estimate)) + 
  geom_sf(color = NA) + 
  coord_sf(crs = 26911) + 
  scale_fill_viridis_c(option = "magma") 
Atlantic




ny <- get_acs(geography = "tract", 
              variables = "B19013_001", 
              state = "NY", 
              county = "New York", 
              geometry = TRUE)

ggplot(ny, aes(fill = estimate)) + 
  geom_sf() + 
  theme_void() + 
  scale_fill_viridis_c(labels = scales::dollar)
