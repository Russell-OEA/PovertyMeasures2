### -------------------------------------------
### Calculates lists of communities meeting different affordable thresholds. 
### Project for water group
### Last Updated: 12/17/2021
### Contact: Mike Russell, Michael.Russell@dep.nj.gov
### -------------------------------------------

# Set to working directory ----------------------------
setwd("~/R/Projects/PovertyMeasures2") # Change as needed

### Load libraries ----------------------------
### -------------------------------------------

library(tidyverse)
library(readr)
library(readxl)

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


### ------------------------------------------------------------------- ###
### Download source files from web ------------------------------------ ###
### (Uncomment below if files are not already in the working directory) ###
### ------------------------------------------------------------------- ###
### NOTE: For the OBC list, you will need to download the file manually ---- ###
### from here: https://www.nj.gov/dep/ej/docs/overburdenedcommunitylist.xlsx ###
### and resave as a CSV in the working directory. -------------------------- ###
### ------------------------------------------------------------------------ ###
### NOTE: For the MRI list, you will need to download the file manually ---- ###
### from here: https://www.nj.gov/dca/home/2020_MRI_Scores_and_Rankings.xlsx ###
### and move the file to the working directory. ---------------------------- ###
### -------------------------------------------------------------------------------------------------- ###
### NOTE: For the HMI list, you will need to download the file manually ------------------------------ ###
### from here: https://www.hudexchange.info/sites/onecpd/assets/File/ACS_2015_lowmod_localgov_all.xlsx ###
### and resave as a CSV in the working directory. ---------------------------------------------------- ###
### -------------------------------------------------------------------------------------------------- ###


# DO NOT USE download.file("https://www.nj.gov/dca/home/2020_MRI_Scores_and_Rankings.xlsx", "./2020_MRI_Scores_and_Rankings.xlsx")
# DO NOT USE download.file("https://www.hudexchange.info/sites/onecpd/assets/File/ACS_2015_lowmod_localgov_all.xlsx", "./ACS_2015_lowmod_localgov_all.xlsx")
download.file("https://raw.githubusercontent.com/Russell-OEA/NJ-Muni_Code_Crosswalk/main/Muni_Code_Crosswalk.csv", "./Muni_Code_Crosswalk.csv")
download.file("https://raw.githubusercontent.com/Russell-OEA/NJ_County_Unemployment/main/NJ_County_Unemp_2019.csv", "./NJ_County_Unemp.csv")



### ---------------------------------###
### Import data from outside sources ###
### ---------------------------------###

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

# LMI 
# Source: https://www.hudexchange.info/programs/acs-low-mod-summary-data/acs-low-mod-summary-data-local-government/
LMI_data <- read_csv("ACS_2015_lowmod_localgov_all.csv", #imports file
                     col_types = cols(LOWMOD_PCT = col_number())) #sets percent column to numeric
# County Unemployment Rates
# Source: https://www.nj.gov/labor/lpa/employ/uirate/fmth_2010-2020.xlsx
# CSV available at: 
NJ_County_Unemp <- read_csv("NJ_County_Unemp.csv")

# OBC List
# Source: NJDEP OEJ Website
# CSV available at: https://www.nj.gov/dep/ej/docs/overburdenedcommunitylist.xlsx
OBC_Data <- read_csv("overburdenedcommunitylist.csv", 
                     skip = 3)

# NJ State Municipal Code - FIPS Code Crosswalk
# Source:
# CSV available at: 
Muni_Code_Crosswalk <- read_csv("Muni_Code_Crosswalk.csv")
# NJ Statewide MHI
# Source: https://www.census.gov/quickfacts/NJ
NJ_MHI <- 82545



# Clean data
MRI_data <- 
  MRI_data %>% 
  filter(!is.na(CODE)) %>% # Removes extra header rows, layout rows, etc. from Excel sheet
  select(CODE, Muni, County, Region, MRI_Score, MRI_Rank, PopChange_Value, PovertyRate_Value, MHI_Value, Unemp_Value) # removes all but the selected columns
MRI_data$PopChange_Value <- MRI_data$PopChange_Value * 100 # Converts rate from decimal to percent value to make comparison easier
MRI_data$PovertyRate_Value <- MRI_data$PovertyRate_Value * 100
MRI_data$Unemp_Value <- MRI_data$Unemp_Value * 100


LMI_data <- 
  LMI_data %>%
  filter(STATE == 34, # Filters out all non-NJ states
         !is.na(COUSUB)) %>% # Filters out all places and leaves COUSUB entries only
  select(NAME, COUSUB, LOWMOD_PCT)

Muni_Code_Crosswalk <- rename(Muni_Code_Crosswalk, COUSUB = MCD) # Rename header for MCD to align with LMI_data
Muni_Code_Crosswalk <- 
  Muni_Code_Crosswalk %>% 
  filter(!is.na(CODE)) %>% # Removes Counties and CDPs
  select("AREA NAME", COUSUB, CODE, CNTY)

OBC_Data2 <- rename(OBC_Data, CODE = "Municipality Code")
OBC_Data2 <- rename(OBC_Data2, OBC_Type = "Overburdened Community Criteria")
OBC_Data2 <- 
  OBC_Data2 %>% 
  select(CODE, OBC_Type, Municipality)
#OBC_Data <- filter(
#  OBC_Data, str_detect(OBC_Data$OBC_Type, "Low Income") == TRUE
#)
OBC_Data2 <- distinct(OBC_Data2, CODE, .keep_all = TRUE)


Poverty_data <- full_join(Muni_Code_Crosswalk, MRI_data, by = "CODE") # merge MRI data with crosswalk table
Poverty_data <- full_join(Poverty_data, LMI_data, by = "COUSUB") # merge with LMI table
Poverty_data <- full_join(Poverty_data, NJ_County_Unemp, by = "CNTY") # merge with county unemployment data
Poverty_data <- right_join(OBC_Data2, Poverty_data, by = "CODE")

###########

Poverty_data <- 
  Poverty_data %>%
  mutate(LMI_60_Percent = if_else(LOWMOD_PCT >= 60, "Yes", "No")) %>% #Creates column for munis with LMI >= 60%
  mutate(LMI_51_Percent = if_else(LOWMOD_PCT >= 51, "Yes", "No")) %>% #Creates column for munis with LMI >= 59%
  mutate(Drinking_threshold = if_else((MHI_Value / NJ_MHI * 100) < 65, "Yes", "No")) %>% #Creates column using Drinking Water's calculation
  mutate(Clean_threshold = if_else(MHI_Value < 90000 | Unemp_Value > 4 | PopChange_Value < 2, "Yes", "No")) %>% #Creates column using Clean Water's threshold
  mutate(OBC_threshold = if_else(!is.na(OBC_Type), "Yes", "No"))



####

Poverty_Data_Final <- Poverty_data %>% select(CODE, COUSUB, Muni, County.x, MRI_Rank, LMI_51_Percent, OBC_threshold, Unemp_Value)

# p <- ggplot() 
# 
# #p <- p + geom_histogram(data = Poverty_Data_Final, aes(x = Unemp_Value, y = ..count.., 
#                                                   color = OBC_threshold, fill = OBC_threshold),
#                         stat = "bin", bins = 15, size = 1, alpha = 0.7, position = "identity")
# 
# p <- p + geom_density_ridges(data = Poverty_Data_Final, aes(x = Unemp_Value, y = OBC_threshold, 
#                                                        fill = OBC_threshold),
#                              color = "white")
# 
# 
# p
#  
#  # p <- p + geom_boxplot()
# 
# Poverty_data %>% 
#   mutate(bin = cut(Unemp_Value, breaks = c(Inf, 1, 2, 3, 4, 5))) %>%
#   # count(bin) %>%
#   group_by(OBC_threshold, bin)  %>%
#   summarize() 
# 
# 
# p <- geom_histogram()
#  
# p
# 
# State_ave <- mean(Poverty_data$Unemp_Value)

Poverty_data %>%
  #group_by(OBC_threshold) %>%
  #summarise(Unemp_Value > State_ave) %>%
  count(Unemp_Value > ANN_AV_UNEMP_RATE, OBC_threshold)

OBC_County <- Poverty_data %>%
  #group_by(OBC_threshold) %>%
  #summarise(Unemp_Value > State_ave) %>%
  count(County, OBC_threshold)


p <- ggplot(data = Poverty_data,
            mapping = aes(x = reorder(County, Unemp_Value, na.rm=TRUE),
                          y = Unemp_Value, color = OBC_threshold))
p + geom_point(size = 2) +
  facet_wrap(~ Unemp_Value > ANN_AV_UNEMP_RATE, ncol = 1) +
  geom_jitter() + labs(NULL) + 
  coord_flip() + theme(legend.position = "top")


q <- ggplot(data = Poverty_data,
            mapping = aes(x = reorder(County, Unemp_Value, na.rm=TRUE),
                          y = Unemp_Value, color = Unemp_Value > ANN_AV_UNEMP_RATE))
q + geom_point(size = 2) +
  facet_wrap(~ OBC_threshold, ncol = 1) +
  geom_jitter() + labs(NULL) + 
  coord_flip() + theme(legend.position = "top")
