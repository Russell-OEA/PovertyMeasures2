setwd("~/R/Projects/Poverty Measures")

### Calculates lists of communities meeting different affordable thresholds. 
### Project for water group
### 12/13/2021

# Load libraries
#install.packages("tidyverse")
library(tidyverse)
library(readxl)
library(ggplot2)
library(hrbrthemes)
library(GET)


# Create column names for MRI dataset
MRI_columns <- c("Muni_Code", 
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
                 
                 


### Load datasets

# Use this to load a local copy of MRI data from the working directory:

# not working: download.file(url="https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FDATA.gov_NGAP.xlsx",
# not working:    destfile="./R/Projects/Poverty Measures/2020_MRI_Scores_and_Rankings2.xlsx")

MRI_data <- read_excel("2020_MRI_Scores_and_Rankings.xlsx", sheet = "2020 MRI - Alphabetical", col_names = MRI_columns)

# Use this to load the 2020 version directly from DCA's website:
MRI_data <- read_excel("https://www.nj.gov/dca/home/2020_MRI_Scores_and_Rankings.xlsx", sheet = "2020 MRI - Alphabetical", col_names = MRI_columns)

# not working:  GET(url = "https://www.nj.gov/dca/home/2020_MRI_Scores_and_Rankings.xlsx",
    write_disk(test1) )

# Clean datasets
MRI_data2 <- MRI_data %>% filter(!is.na(Muni_Code)) #Removes extra columns from Excel sheet

## Sandboxing visualization
## Not used at this point
# 
# Test <- read_excel("Test.xlsx")
# 
# p <- ggplot(data = Test, mapping = aes(x = Year, y = Value, color = Type)) +
#   geom_point(size=3, aes(group=Type)) +
#   xlab("") +
#   theme_ipsum() +
#   facet_wrap(~ Group, ncol = 3) 
# p

