transform_to_Ne<-function(indNe_data, ratio=0.1){
## This functions gets the Nc data from point or range estimates and transforms it to Ne 
## multiplying for a ratio Ne:Ne (defaults to 0.1 if none provided)
 
## Arguments
## indNe_data as produced by get_indicatorNe_data()
## desired Ne:Nc ratio. Should range 0-1. Defaults to 0.1
  
## output
## Original indNe_data df with more columns for Ne:
# Nc_from_range (conversion of "more than..." to numbers)
# Ne_from_Nc: Ne estimated from NcRange or NcPoint  
# Ne_combined: Ne estimated from Ne if Ne is available, otherwise, from Nc
# NeLower_from_Nc, NeUpper_from_Nc: lower and upper intervals transformed to Ne when data is NcPoint
# Ne_calculated_from: specifies for each population were the data to estimate Ne came from. Options are:  "genetic data", "NcPoint ratio", and "NcRange ratio"
  
  ### Function
  
## check ratio: 
ratio=ratio

if (!is.numeric(ratio) || ratio < 0 || ratio > 1) {
  stop("Invalid argument. Please provide a number within the range 0 to 1, using `.` to delimit decimals.")
} else {
      
    ## process data:
      indNe_data = indNe_data
      
      indNe_data<-indNe_data %>% 
        
        # transform NcRange values to numeric values
        mutate(Nc_from_range = case_when(
              NcRange == "more_5000_bymuch" ~ 10000,
              NcRange == "more_5000" ~ 5500,
              NcRange == "less_5000_bymuch" ~ 500,
              NcRange == "less_5000" ~ 4050,
              NcRange == "range_includes_5000" ~ 5001)) %>% 
        
        # Get Ne from Nc data 
        mutate(Ne_from_Nc = case_when(
                    #if there is NcPoint data, use it multiplying by the ratio
                    !is.na(NcPoint) ~ NcPoint*ratio, 
                    
                    # if there is NcRange data (already converted to numeric values), use it multiplying by the ratio
                    !is.na(Nc_from_range) ~ Nc_from_range * ratio)) %>% 
        
        # Get lower and upper Ne intervals from Nc point data
          # if there is NcPoint LOWER bound data, use it multiplying by the ratio
          mutate(NeLower_from_Nc = case_when(!is.na(NcLower) ~ NcLower*ratio))  %>%
          
          # if there is NcPoint UPPER bound data, use it multiplying by the ratio
          mutate(NeUpper_from_Nc = case_when(!is.na(NcUpper) ~ NcUpper*ratio))  %>%
        
               
        # Get the Ne combining all different sources
        mutate(Ne_combined = if_else(is.na(Ne), # here TRUE means Ne is NA
                                     Ne_from_Nc, # if genetic data is not available (Ne is NA) then use the Ne estimated from Nc data
                                     Ne)) %>% # if there is Ne from genetic data, use it
        
        # Create a new variable specifying for each population were the data to estimate Ne came from
        mutate(Ne_calculated_from = if_else(is.na(Ne),  # here TRUE means Ne is NA
                                        
                                        # if Ne is missing check what type of Ncdata was used and use NcPoint/NcRange ratio accordingly
                                        if_else(!is.na(NcPoint), "NcPoint ratio", 
                                                
                                                # if Nc_from_range exists and write "NcRange ratio"
                                                if_else(!is.na(Nc_from_range), "NcRange ratio", 
                                                        
                                                        # If neither NcPoint nor Nc_from_range exists, flag it as missing data
                                                        NA_character_)
                                                ),
                                        
                                        # If Ne is NOT missing, write "genetic" source
                                        "genetic data")
               ) 
        
      print(indNe_data)
    }
}
