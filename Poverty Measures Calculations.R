# Set to working director 
# setwd("~/R/Projects/Poverty Measures") # Work drive
 setwd("~/Documents/GitHub/PovertyMeasures") # Home drive

### Calculates lists of communities meeting different affordable thresholds. 
### Project for water group
### 12/13/2021

# Load libraries
install.packages("tidyverse")
library(tidyverse)
library(readr)
library(readxl)
library(ggplot2)
# library(hrbrthemes)
# library(GET)


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
                 
                 


### Import data

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

# LMI
# Source: https://www.hudexchange.info/programs/acs-low-mod-summary-data/acs-low-mod-summary-data-local-government/
LMI_data <- LMI_data %>% read_csv("ACS_2015_lowmod_localgov_all.csv", 
                                         col_types = cols(LOWMOD_PCT = col_number()))
# County Unemployment Rates
# Source: https://nj.gov/labor/lpa/LMI_index.html?_ga=2.184612201.1711518215.1639619183-285857380.1639619183
# CSV available at: 
NJ_County_Unemp <- read_csv("NJ_County_Unemp.csv")

# NJ State Municipal Code - FIPS Code Crosswalk
# Source:
# CSV available at: 
Muni_Code_Crosswalk <- read_csv("Muni_Code_Crosswalk.csv")

# NJ Statewide MHI
# Source: https://www.census.gov/quickfacts/NJ
NJ_MHI <- 82545

# Clean data
MRI_data <- MRI_data %>% filter(!is.na(CODE)) # Removes extra header rows, layout rows, etc. from Excel sheet
LMI_data <- LMI_data %>% filter(STATE == 34) # Filters out all non-NJ states
Muni_Code_Crosswalk <- Muni_Code_Crosswalk %>% filter(!is.na(CODE)) # Removes Counties and CDPs
Muni_Code_Crosswalk <- rename(Muni_Code_Crosswalk, COUSUB = MCD) # Rename header for MCD to align with LMI_data

