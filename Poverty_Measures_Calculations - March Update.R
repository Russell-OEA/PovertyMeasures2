# -------------------------------------------
# Calculates lists of communities meeting different affordable thresholds. 
# Project for water group
# Last Updated: 12/17/2021
# Contact: Mike Russell, Michael.Russell@dep.nj.gov
# -------------------------------------------

# Set to working directory ----------------------------
setwd("~/R/Projects/PovertyMeasures2") # Change as needed

# Load libraries ----------------------------
# -------------------------------------------

library(tidyverse)
library(readr)
library(readxl)
library(knitr)
library(ezknitr)

# Create column names for MRI dataset
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
                 

# ------------------------------------------------------------------- 
# Download source files from web ------------------------------------ 
# (Uncomment below if files are not already in the working directory) 
# -------------------------------------------------------------------
# NOTE: For the OBC list, you will need to download the file manually ----
# from here: https://www.nj.gov/dep/ej/docs/overburdenedcommunitylist.xlsx 
# and resave as a CSV in the working directory. --------------------------
# ------------------------------------------------------------------------
# NOTE: For the MRI list, you will need to download the file manually ----
# from here: https://www.nj.gov/dca/home/2020_MRI_Scores_and_Rankings.xlsx 
# and move the file to the working directory. ----------------------------
# --------------------------------------------------------------------------------------------------
# NOTE: For the HMI list, you will need to download the file manually ------------------------------
# from here: https://www.hudexchange.info/sites/onecpd/assets/File/ACS_2015_lowmod_localgov_all.xlsx 
# and resave as a CSV in the working directory. ----------------------------------------------------
# --------------------------------------------------------------------------------------------------


# DO NOT USE download.file("https://www.nj.gov/dca/home/2020_MRI_Scores_and_Rankings.xlsx", "./2020_MRI_Scores_and_Rankings.xlsx")
# DO NOT USE download.file("https://www.hudexchange.info/sites/onecpd/assets/File/ACS_2015_lowmod_localgov_all.xlsx", "./ACS_2015_lowmod_localgov_all.xlsx")
#download.file("https://raw.githubusercontent.com/Russell-OEA/NJ-Muni_Code_Crosswalk/main/Muni_Code_Crosswalk.csv", "./Muni_Code_Crosswalk.csv")
#download.file("https://raw.githubusercontent.com/Russell-OEA/NJ_County_Unemployment/main/NJ_County_Unemp.csv", "./NJ_County_Unemp.csv")


# ---------------------------------
# Import data from outside sources 
# --------------------------------

# MRI: 
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
NJ_State_Pop <- -0.03

# LMI 
# Source: https://www.hudexchange.info/programs/acs-low-mod-summary-data/acs-low-mod-summary-data-local-government/

#LMI_data <- read_csv("ACS_2015_lowmod_localgov_all.csv", #imports file
#                                         col_types = cols(LOWMOD_PCT = col_number())) #sets percent column to numeric

# County Unemployment Rates
# Source: https://www.nj.gov/labor/lpa/employ/uirate/fmth_2010-2020.xlsx
# CSV available at: 
NJ_County_Unemp <- read_csv("NJ_County_Unemp_2019.csv",
                            col_types = cols(CNTY = col_character()))
NJ_State_Unemp <- 3.4

# OBC List
# Source: NJDEP OEJ Website
# CSV available at: https://www.nj.gov/dep/ej/docs/overburdenedcommunitylist.xlsx

# OBC_Data <- read_csv("overburdenedcommunitylist.csv", 
#                     skip = 3)

# Data for OBC-style metric at community level
# Source: Census
# CSV available at: https://censusreporter.org/data/table/?table=C17002&geo_ids=04000US34,310|04000US34,060|04000US34&primary_geo_id=04000US34#
EJ_Def_Data <- read_csv("ACS_Poverty_Measures_EJ_Def.csv")

# NJ State Municipal Code - FIPS Code Crosswalk
# Source:
# CSV available at: 
Muni_Code_Crosswalk <- read_csv("Muni_Code_Crosswalk.csv")
# NJ Statewide MHI
# Source: https://www.census.gov/quickfacts/NJ
NJ_MHI <- 82545

# Clean_water_data <- read_csv("PCWS_w_Muni.csv")

# Clean data
MRI_data <- 
  MRI_data %>% 
  filter(!is.na(CODE)) %>% # Removes extra header rows, layout rows, etc. from Excel sheet
  select(CODE, Muni, County, Region, MRI_Score, MRI_Rank, PopChange_Value, PovertyRate_Value, MHI_Value, Unemp_Value) # removes all but the selected columns
MRI_data$PopChange_Value <- MRI_data$PopChange_Value * 100 # Converts rate from decimal to percent value to make comparison easier
MRI_data$PopChange_Value <- round(MRI_data$PopChange_Value, 2)
MRI_data$NJ_State_Pop <- NJ_State_Pop
MRI_data$PopChange_Diff <- MRI_data$PopChange_Value - MRI_data$NJ_State_Pop
MRI_data$PovertyRate_Value <- MRI_data$PovertyRate_Value * 100
MRI_data$Unemp_Value <- MRI_data$Unemp_Value * 100

NJ_County_Unemp <-
  NJ_County_Unemp %>%
  filter(!is.na(STATE)) 
NJ_County_Unemp$NJ_State_Unemp <- NJ_State_Unemp
NJ_County_Unemp$Unemp_Diff <- NJ_County_Unemp$ANN_AV_UNEMP_RATE - NJ_County_Unemp$NJ_State_Unemp

# LMI_data <- 
#   LMI_data %>%
#   filter(STATE == 34, # Filters out all non-NJ states
#   !is.na(COUSUB)) %>% # Filters out all places and leaves COUSUB entries only
#   select(NAME, COUSUB, LOWMOD_PCT)

EJ_Def_Data <- 
  EJ_Def_Data %>% 
  dplyr::filter(!grepl('31000|04000',geoid)) %>% #remove state and MSA values, leave community
  mutate(COUSUB = substr(geoid, nchar(geoid)-5+1, nchar(geoid))) %>% #strip down geoid for merging
  select(name, C17002001, C17002008, COUSUB) #pull only data used in EJ tool calculation
EJ_Def_Data$OBC_Poverty_Percent <- ((EJ_Def_Data$C17002001 - EJ_Def_Data$C17002008) / EJ_Def_Data$C17002001 * 100)
EJ_Def_Data$OBC_Poverty_Percent <- round(EJ_Def_Data$OBC_Poverty_Percent, 2)
                         
Muni_Code_Crosswalk <- rename(Muni_Code_Crosswalk, COUSUB = MCD) # Rename header for MCD to align with LMI_data
Muni_Code_Crosswalk <- 
  Muni_Code_Crosswalk %>% 
  filter(!is.na(CODE)) %>% # Removes Counties and CDPs
  select("AREA NAME", COUSUB, CODE, CNTY)

# OBC_Data <- rename(OBC_Data, CODE = "Municipality Code")
# OBC_Data <- rename(OBC_Data, OBC_Type = "Overburdened Community Criteria")
# OBC_Data <- 
#   OBC_Data %>% 
#   select(CODE, OBC_Type)
# OBC_Data <- filter(
#     OBC_Data, str_detect(OBC_Data$OBC_Type, "Low Income") == TRUE
#     )
# OBC_Data <- distinct(OBC_Data, CODE, .keep_all = TRUE)
# 
# Clean_water_data <- rename(Clean_water_data, CODE = "MUN_CODE")
# Clean_water_data <- 
#   Clean_water_data %>%
#   select(PI_ID, PWID, SYS_NAME, AREA_TYPE, POP2010, POPDEN2010, CODE, NAME)

###########

Poverty_data <- full_join(Muni_Code_Crosswalk, MRI_data, by = "CODE") # merge MRI data with crosswalk table
#Poverty_data <- full_join(Poverty_data, LMI_data, by = "COUSUB") # merge with LMI table
Poverty_data <- full_join(Poverty_data, NJ_County_Unemp, by = "CNTY") # merge with county unemployment data
#Poverty_data <- right_join(OBC_Data, Poverty_data, by = "CODE")
Poverty_data <- left_join(EJ_Def_Data, Poverty_data, by = "COUSUB")

###########

Poverty_data <- 
  Poverty_data %>%
    mutate(OBC_Poverty_Threshold = if_else(OBC_Poverty_Percent >= 35, "Meets or exceeds", "Does not meet")) %>%
    mutate(Unemp_Threshold = if_else(Unemp_Diff >= 0, "Meets or exceeds", "Does not meet")) %>%
    mutate(Population_Threshold = if_else(PopChange_Value <= NJ_State_Pop, "Meets or exceeds", "Does not meet")) %>%
    mutate(MHI_Percent_State = MHI_Value / NJ_MHI * 100) %>% #Calculates the muni MHI as a percent of state MHI
    mutate(MHI_Threshold = if_else((MHI_Value / NJ_MHI * 100) < 80, "Meets are exceeds", "Does not meet")) %>% #Creates column using Drinking Water's calculation
    #mutate(OBC_Unemp_Pop = if_else(OBC_Poverty_Percent >= 35 & Unemp_Diff >= 0 & PopChange_Value <= 0, "Yes", "No")) %>%
    #mutate(MHI_Unemp_Pop = if_else(Unemp_Diff > 0 & PopChange_Value <= 0 & (MHI_Value / NJ_MHI * 100) < 90, "Yes", "No")) %>%
    #mutate(All_Thresholds = if_else(OBC_Poverty_Percent >= 35 & Unemp_Diff >= 0 & PopChange_Value <= 0 & (MHI_Value / NJ_MHI * 100) < 90, "Yes", "No")) %>%
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
  

  
  
#older calculations:
  # mutate(LMI_60_Percent = if_else(LOWMOD_PCT >= 60, "Yes", "No")) %>% #Creates column for munis with LMI >= 60%
  # mutate(LMI_51_Percent = if_else(LOWMOD_PCT >= 51, "Yes", "No")) %>% #Creates column for munis with LMI >= 59%
  # mutate(Drinking_threshold = if_else((MHI_Value / NJ_MHI * 100) < 65, "Yes", "No")) %>% #Creates column using Drinking Water's calculation
  # mutate(Clean_threshold = if_else(MHI_Value < 90000 | Unemp_Value > 4 | PopChange_Value < 2, "Yes", "No")) %>% #Creates column using Clean Water's threshold
  # mutate(OBC_threshold = if_else(!is.na(OBC_Type), "Yes", "No"))

####

Poverty_Data_Final <- Poverty_data %>% select(
                                              CODE, COUSUB, Muni, County, MRI_Rank, #general information about communities
                                              OBC_Poverty_Percent, OBC_Poverty_Threshold, # % of population at or below 2x the poverty line, is % > 35
                                              MHI_Value, MHI_Percent_State, MHI_Threshold, # MHI for muni, as a percent of state MHI, is it less than 90% of the state's value
                                              ANN_AV_UNEMP_RATE, Unemp_Diff, Unemp_Threshold, # county unemployment rate, difference from state, is it worse than state
                                              PopChange_Value, PopChange_Diff, Population_Threshold, # population change, is population staying the same or shrinking
                                              Score_Adjustment, Adjusted_Score,
                                              #OBC_Unemp_Pop, MHI_Unemp_Pop, All_Thresholds, #summary categories
                                              Current_Drinking, Current_Clean #existing criteria
                                              ) # summaries

write_csv(Poverty_Data_Final, "./Poverty_Data_Final_03-21-2022_Update.csv")
#' 
#' ####
#' 
#' Clean_water_data <- full_join(Clean_water_data, Poverty_Data_Final, by = "CODE")
#' 
#' Munis_without_WS_data <-
#'   Clean_water_data %>%
#'   filter(is.na(PWID)) %>%
#'   select(CODE, COUSUB, Muni, County, MRI_Rank, LMI_60_Percent, LMI_51_Percent, Drinking_threshold, Clean_threshold, OBC_threshold)
#' 
#' Clean_water_data <- 
#'   Clean_water_data %>%
#'   filter(!is.na(PWID)) %>%
#'   select(PI_ID, PWID, SYS_NAME, AREA_TYPE, POP2010, POPDEN2010, CODE, COUSUB, Muni, County, MRI_Rank, LMI_60_Percent, LMI_51_Percent, Drinking_threshold, Clean_threshold, OBC_threshold)
#' 
#' # Clean_water_data %>%
#' #  group_by(PWID, Clean_threshold) %>%
#' #  summarize(sum(POP2010)) %>%
#' #  mutate(percent = pop2010 / sum(POP2010))
#' 
#' # test <- Clean_water_data %>%
#' #   group_by(PWID, Clean_threshold) %>%
#' #   mutate(percent = prop.table(POP2010))
#' # 
#' # test3 <- 
#' #   Clean_water_data %>%
#' #   group_by(SYS_NAME, Clean_threshold) %>%
#' #   summarise(Agg_Pop = sum(POP2010))
#' 
#' #' ## Basics
#' #' - Any line that starts with `#'` is treated as Markdown. 
#' #' - Any line that starts with `#+` is treated as a code chunk. Code chunks are how code
#' #' and text are integrated in R Markdown. You can specify options like `echo = FALSE` as you
#' #' would in an R Markdown code chunk.
#' #' 
#' #' 
#' #' ## Example "analysis"
#' #' A quick example to show how the code and text integrate. The `gapminder` data is
#' #'  available as a package so you should be able to reproduce this file by just hitting 
#' #'  "compile notebook" in RStudio. 
#' 
#' # test <- kable(Poverty_Data_Final)
#' # kable(
#' #   head(Poverty_Data_Final[, 1:10]), "simple",
#' #   caption = 'test'
#' # )
