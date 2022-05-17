# Create external tables -----
# Should redo with loops and functions at some point, but this works

county_display_filter_variables <- c(
  "Muni", 
  "MHI_Percent_State", 
  "ANN_AV_UNEMP_RATE", 
  "PopChange_Value", 
  "Adjusted_Score"
)

column_names_external <- c("Name","MHI Percent", "County Unemp", "Population Change", "Adjusted Score")

table.Atlantic_external <- Poverty_Data_Final %>%
  filter(County == "Atlantic") %>%
  select(county_display_filter_variables)

table.Bergen_external <- Poverty_Data_Final %>%
  filter(County == "Bergen") %>%
  select(county_display_filter_variables)

table.Burlington_external <- Poverty_Data_Final %>%
  filter(County == "Burlington") %>%
  select(county_display_filter_variables)

table.Camden_external <- Poverty_Data_Final %>%
  filter(County == "Camden") %>%
  select(county_display_filter_variables)

table.Cape_May_external <- Poverty_Data_Final %>%
  filter(County == "Cape May") %>%
  select(county_display_filter_variables)

table.Cumberland_external <- Poverty_Data_Final %>%
  filter(County == "Cumberland") %>%
  select(county_display_filter_variables)

table.Essex_external <- Poverty_Data_Final %>%
  filter(County == "Essex") %>%
  select(county_display_filter_variables)

table.Gloucester_external <- Poverty_Data_Final %>%
  filter(County == "Gloucester") %>%
  select(county_display_filter_variables)

table.Hudson_external <- Poverty_Data_Final %>%
  filter(County == "Hudson") %>%
  select(county_display_filter_variables)

table.Hunterdon_external <- Poverty_Data_Final %>%
  filter(County == "Hunterdon") %>%
  select(county_display_filter_variables)

table.Mercer_external <- Poverty_Data_Final %>%
  filter(County == "Mercer") %>%
  select(county_display_filter_variables)

table.Middlesex_external <- Poverty_Data_Final %>%
  filter(County == "Middlesex") %>%
  select(county_display_filter_variables)

table.Monmouth_external <- Poverty_Data_Final %>%
  filter(County == "Monmouth") %>%
  select(county_display_filter_variables)

table.Morris_external <- Poverty_Data_Final %>%
  filter(County == "Morris") %>%
  select(county_display_filter_variables)

table.Ocean_external <- Poverty_Data_Final %>%
  filter(County == "Ocean") %>%
  select(county_display_filter_variables)

table.Passaic_external <- Poverty_Data_Final %>%
  filter(County == "Passaic") %>%
  select(county_display_filter_variables)

table.Somerset_external <- Poverty_Data_Final %>%
  filter(County == "Somerset") %>%
  select(county_display_filter_variables)

table.Salem_external <- Poverty_Data_Final %>%
  filter(County == "Salem") %>%
  select(county_display_filter_variables)

table.Sussex_external <- Poverty_Data_Final %>%
  filter(County == "Sussex") %>%
  select(county_display_filter_variables)

table.Union_external <- Poverty_Data_Final %>%
  filter(County == "Union") %>%
  select(county_display_filter_variables)

table.Warren_external <- Poverty_Data_Final %>%
  filter(County == "Warren") %>%
  select(county_display_filter_variables)
