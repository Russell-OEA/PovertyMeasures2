# Calculates lists of communities meeting different affordable thresholds -----
# Project for water group
# Last Updated: 05/16/2022
# Contact: Mike Russell, Michael.Russell@dep.nj.gov

# Load packages -----

library(tidyverse)
library(readr)
library(readxl)
library(knitr)
library(ezknitr)

# Importing Data -----

## MRI -----
# MRI data has municipal unemployment and population change
# Future versions of this analysis will pull from ACS directly

### Create column names for MRI dataset -----
# This helps with importing the MRI data


MRI_columns <- c("CODE", 
                 "Muni",
                 "County",
                 "Region",
                 "MRI_Score",
                 "MRI_Distress", 
                 "MRI_Rank", 
                 "PopChange_Rank",
                 "PopChange_Index",
                 "PopChange_Value",
                 "HousingVacancy_Rank",
                 "HousingVacancy_Index",
                 "HousingVacancy_Value",
                 "SNAPPercent_Rank",
                 "SNAPPercent_Index",
                 "SNAPPercent_Value",
                 "TANFRate_Rank",
                 "TANFRate_Index",
                 "TANFRate_Value",
                 "PovertyRate_Rank",
                 "PovertyRate_Index",
                 "PovertyRate_Value",
                 "MHI_Rank",
                 "MHI_Index",
                 "MHI_Value",
                 "Unemp_Rank",
                 "Unemp_Index",
                 "Unemp_Value",
                 "HSDiploma_Rank",
                 "HSDiploma_Index",
                 "HSDiploma_Value",
                 "PropTaxRate_Rank",
                 "PropTaxRate_Index",
                 "PropTaxRate_Value",
                 "PerCapitaValuation_Rank",
                 "PerCapitaValuation_Index",
                 "PerCapitaValuation_Value",
                 "Urban_Aid")

### Import MRI dataset: -----
# Source: https://www.nj.gov/dca/home/MuniRevitIndex.html
MRI_data <- read_excel("2020_MRI_Scores_and_Rankings.xlsx", # imports file
                       sheet = "2020 MRI - Alphabetical", # selects correct Excel worksheet
                       col_types = c("text", "text", "text", # sets value columns to numeric, ignore errors
                                     "text", "text", "text", "text", "text", 
                                     "text", "numeric", "text", "text", 
                                     "numeric", "text", "text", "numeric", 
                                     "text", "text", "numeric", "text", 
                                     "text", "numeric", "text", "text", 
                                     "numeric", "text", "text", "numeric", 
                                     "text", "text", "numeric", "text", 
                                     "text", "numeric", "text", "text", 
                                     "numeric", "text"),
                       col_names = MRI_columns) # names columns 
remove(MRI_columns) # removes column names from working environment after they've been added to the table 

### State Average ----

NJ_State_Pop <- -0.03 

## Unemployment -----

### County Unemployment Rates -----
# Using 2019 data to avoid pandemic-related distortion
# Source: https://www.nj.gov/labor/lpa/employ/uirate/fmth_2010-2020.xlsx

NJ_County_Unemp <- read_csv("NJ_County_Unemp_2019.csv",
                            col_types = cols(CNTY = col_character()))

### State Unemployment Rate -----
NJ_State_Unemp <- 3.4

## OBC / Poverty -----

### Data for OBC-style metric at community level -----
# Source: Census
# CSV available at: https://censusreporter.org/data/table/?table=C17002&geo_ids=04000US34,310|04000US34,060|04000US34&primary_geo_id=04000US34#

EJ_Def_Data <- read_csv("ACS_Poverty_Measures_EJ_Def.csv")

## NJ State Municipal Code - FIPS Code Crosswalk -----
# Simple crosswalk table to allow merging later

Muni_Code_Crosswalk <- read_csv("Muni_Code_Crosswalk.csv")

## NJ Statewide MHI -----
# Source: https://www.census.gov/quickfacts/NJ
NJ_MHI <- 85245 

# Cleaning Data -----

## MRI -----

MRI_data <- 
  MRI_data %>% 
  filter(!is.na(CODE)) %>% # Removes extra header rows, layout rows, etc. from Excel sheet
  select(CODE, Muni, County, Region, MRI_Score, MRI_Rank, PopChange_Value, PovertyRate_Value, MHI_Value, Unemp_Value) # removes all but the selected columns
MRI_data$PopChange_Value <- MRI_data$PopChange_Value * 100 # Converts rate from decimal to percent value to make comparison easier
MRI_data$PopChange_Value <- round(MRI_data$PopChange_Value, 2) # rounds for easy comparison
MRI_data$NJ_State_Pop <- NJ_State_Pop # adds state pop change for comparison below
MRI_data$PopChange_Diff <- MRI_data$PopChange_Value - MRI_data$NJ_State_Pop # compares muni to state average
MRI_data$PovertyRate_Value <- MRI_data$PovertyRate_Value * 100 # percent conversion
MRI_data$Unemp_Value <- MRI_data$Unemp_Value * 100 # percent conversion

## Unemployment -----

NJ_County_Unemp$NJ_State_Unemp <- NJ_State_Unemp # adds column for statewide average for comparison
NJ_County_Unemp$Unemp_Diff <- NJ_County_Unemp$ANN_AV_UNEMP_RATE - NJ_County_Unemp$NJ_State_Unemp # compares muni to state average

## OBC -----
# The process below is essentially the same as described here: https://www.nj.gov/dep/ej/docs/obc-technical-document.pdf 

EJ_Def_Data <- 
  EJ_Def_Data %>% 
  dplyr::filter(!grepl('31000|04000',geoid)) %>% #remove state and MSA values, leave community
  mutate(COUSUB = substr(geoid, nchar(geoid)-5+1, nchar(geoid))) %>% #strip down geoid for merging
  select(name, C17002001, C17002008, COUSUB) #pull only data used in EJ tool calculation
EJ_Def_Data$OBC_Poverty_Percent <- ((EJ_Def_Data$C17002001 - EJ_Def_Data$C17002008) / EJ_Def_Data$C17002001 * 100) #finds percent of population at 2x poverty rate
EJ_Def_Data$OBC_Poverty_Percent <- round(EJ_Def_Data$OBC_Poverty_Percent, 2)


## Crosswalk -----

Muni_Code_Crosswalk <- rename(Muni_Code_Crosswalk, COUSUB = MCD) # Rename header for other data
Muni_Code_Crosswalk <- 
  Muni_Code_Crosswalk %>% 
  filter(!is.na(CODE)) %>% # Removes Counties and CDPs
  select("AREA NAME", COUSUB, CODE, CNTY)


# Merge Datasets -----
# Merges MRI, county unemployment, and poverty data into one table

Poverty_data <- full_join(Muni_Code_Crosswalk, MRI_data, by = "CODE") # merge MRI data with crosswalk table
Poverty_data <- full_join(Poverty_data, NJ_County_Unemp, by = "CNTY") # merge with county unemployment data
Poverty_data <- left_join(EJ_Def_Data, Poverty_data, by = "COUSUB")



# Calculate Criteria -----

Poverty_data <- 
  Poverty_data %>%
  mutate(OBC_Poverty_Threshold = if_else(OBC_Poverty_Percent >= 35, "Meets or exceeds", "Does not meet")) %>%
  mutate(Unemp_Threshold = if_else(Unemp_Diff >= 0, "Meets or exceeds", "Does not meet")) %>%
  mutate(Population_Threshold = if_else(PopChange_Value <= NJ_State_Pop, "Meets or exceeds", "Does not meet")) %>%
  mutate(MHI_Percent_State = MHI_Value / NJ_MHI * 100) %>% #Calculates the muni MHI as a percent of state MHI
  mutate(MHI_Threshold = if_else((MHI_Value / NJ_MHI * 100) < 80, "Meets are exceeds", "Does not meet")) %>% 
  mutate(Current_Drinking = if_else((MHI_Value / NJ_MHI * 100) <= 65, "Qualifies", "Does not qualify")) %>% #Creates column using Drinking Water's calculation
  mutate(Current_Clean = if_else(MHI_Value <= 90000 & Unemp_Value >= 5 & PopChange_Value <= 2, "Qualifies", "Does not qualify")) %>% #Creates column using Clean Water's threshold %>%
  mutate(Score_Adjustment = case_when(
    PopChange_Value <= NJ_State_Pop & Unemp_Diff >= 0 ~ "Score adjusted -2",
    PopChange_Value <= NJ_State_Pop | Unemp_Diff >= 0 ~ "Score adjusted -1",
    PopChange_Value > NJ_State_Pop & Unemp_Diff < 0 ~ "Score not adjusted")) %>%
  mutate(Adjusted_Score = case_when(
    PopChange_Value <= NJ_State_Pop & Unemp_Diff >= 0 ~ "-2",
    PopChange_Value <= NJ_State_Pop | Unemp_Diff >= 0 ~ "-1",
    PopChange_Value > NJ_State_Pop & Unemp_Diff < 0 ~ "0"))

Poverty_data <- 
  Poverty_data %>%
  mutate(Adjusted_Score = round(MHI_Percent_State + as.numeric(Adjusted_Score),2))

# Removes extra columns and reorders the data by category

Poverty_Data_Final <- 
  Poverty_data %>% 
  select(
  CODE, COUSUB, Muni, County, MRI_Rank, #general information about communities
  OBC_Poverty_Percent, OBC_Poverty_Threshold, # % of population at or below 2x the poverty line, is % > 35
  MHI_Value, MHI_Percent_State, MHI_Threshold, # MHI for muni, as a percent of state MHI, is it less than 90% of the state's value
  ANN_AV_UNEMP_RATE, Unemp_Diff, Unemp_Threshold, # county unemployment rate, difference from state, is it worse than state
  PopChange_Value, PopChange_Diff, Population_Threshold, # population change, is population staying the same or shrinking
  Score_Adjustment, Adjusted_Score,
  #OBC_Unemp_Pop, MHI_Unemp_Pop, All_Thresholds, #summary categories
  Current_Drinking, Current_Clean #existing criteria
) 


