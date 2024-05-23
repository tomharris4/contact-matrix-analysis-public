# Script for pre-processing contact surveys 

library(socialmixr)
library(hash)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load in all non-national age demographics 
load('Data/China, 2020/Shanghai_demographics.Rda')
load('Data/China, 2020/Wuhan_demographics.Rda')
load('Data/Peru/Peru_demographics.Rda')
load('Data/Zimbabwe/Peri_urban_demographics.Rda')
load('Data/Zimbabwe/Farm_demographics.Rda')


demos <- list(shanghai_demo,wuhan_demo, peru_demo, peri_urban_demo, farm_demo)


# Sample participant age from bounds based on density 
participant_resample <- function(p, dens = NULL){
  age <- p['part_age']
  
  if (grepl("-", age, fixed = TRUE)){
    split <- strsplit(age, "-", fixed = TRUE)
    
    lower <- as.integer(split[[1]][1])
    upper <- as.integer(split[[1]][2])
    
    age <- sample(seq(lower,upper),prob=dens[(lower+1):(upper+1)],size=1)
  }
  
  if (!is.na(age) && (age == "Under 1")){
    age <- 0
  }
  
  return(as.integer(age))
}

# Sample contact age from bounds based on density
contact_resample <- function(c, dens = NULL){

  age <- as.integer(c['cnt_age_exact'])
  lower <- as.integer(c['cnt_age_est_min'])
  upper <- as.integer(c['cnt_age_est_max'])
  
  if (is.na(age) & !is.na(lower) & !is.na(upper)){
    
    lower <- as.integer(c['cnt_age_est_min'])
    upper <- as.integer(c['cnt_age_est_max'])
    
    if (lower == upper){
      return(lower)
    }
    
    age <- sample(seq(lower,upper),prob=dens[(lower+1):(upper+1)],size=1)
  }
  
  return(age)
}

big_contact_checker <- function(c,exc) {
    return(exc[c['part_id']])
}

# Function for censoring participants with large numbers of contacts
group_contact_distribution <- function(contacts) {
  
  
  contacts_map <- hash()
  
  for(a in seq(1,length(contacts$part_id))){
    
    c <- contacts[a,]
    part <- toString(c$part_id)
    
    if (c$cnt_small == 'FALSE'){
      
      if (!(part %in% keys(contacts_map))){
        contacts_map[[part]] <- c(0,0,0,0,0,0,0,0,0,0,0,0)
      }
      
      # increment total contacts
      contacts_map[[part]][1] <- contacts_map[[part]][1] + 1
      
      if(!is.na(c$cnt_age_exact)){
        
        # check if individual contact
        if(!is.na(c$cnt_age_exact) & (!is.na(c$cnt_gender) | !is.na(c$frequency_multi))){
          contacts_map[[part]][2] <- contacts_map[[part]][2] + 1
        } else {
          
          if(c$cnt_age_est_min == '0'){
            if(c['cnt_work'] == TRUE){
              contacts_map[[part]][3] <- contacts_map[[part]][3] + 1
            } else if(c['cnt_school'] == TRUE){
              contacts_map[[part]][4] <- contacts_map[[part]][4] + 1
            } else {
              contacts_map[[part]][5] <- contacts_map[[part]][5] + 1
            }
          } else if(c['cnt_age_est_min'] == '18'){
            if(c['cnt_work'] == TRUE){
              contacts_map[[part]][6] <- contacts_map[[part]][6] + 1
            } else if(c['cnt_school'] == TRUE){
              contacts_map[[part]][7] <- contacts_map[[part]][7] + 1
            } else {
              contacts_map[[part]][8] <- contacts_map[[part]][8] + 1
            }
          } else {
            if(c['cnt_work'] == TRUE){
              contacts_map[[part]][9] <- contacts_map[[part]][9] + 1
            } else if(c['cnt_school'] == TRUE){
              contacts_map[[part]][10] <- contacts_map[[part]][10] + 1
            } else {
              contacts_map[[part]][11] <- contacts_map[[part]][11] + 1
            }
          }
          
          
        }
      } else {
        contacts_map[[part]][12] <- contacts_map[[part]][12] + 1
      }
      
      
    }
  }
  
  return(contacts_map)
}

# 
rescale_contacts <- function(contacts_){
  contacts <- contacts_
  
  for (c in keys(contacts)){
    if (contacts[[c]][2] >= 50){
      contacts[[c]] <- c(50,50,0,0,0,0,0,0,0,0,0,0)
    } else {
      group_total <- contacts[[c]][1] - contacts[[c]][2]
      group_req <- 50 - contacts[[c]][2]
      
      group_scaler <- group_req / group_total
      
      for (i in seq(3,12)){
        contacts[[c]][i] <- as.integer(round(contacts[[c]][i] * group_scaler))
      }
      
      if (sum(contacts[[c]][seq(2,12)]) != 50){
        diff <- 50 - sum(contacts[[c]][seq(2,12)])
        
        max_i <- which.max(contacts[[c]][seq(3,12)])
        
        contacts[[c]][2 + max_i] <- contacts[[c]][2 + max_i] + diff
      }
      
      contacts[[c]][1] <-  sum(contacts[[c]][seq(2,12)])
      
      
    }
    
  }
  
  return(contacts)
}

censor_contacts <- function(contacts,tally){
  
  censor_contacts_out <- c()
  
  for(a in seq(1,length(contacts$part_id))){
    
    c <- contacts[a,]
    part <- toString(c$part_id)
    
    
    if (c$cnt_small == 'FALSE'){
      
      if(!is.na(c$cnt_age_exact)){
      
        # check if individual contact
        if(!is.na(c$cnt_age_exact) & (!is.na(c$cnt_gender) | !is.na(c$frequency_multi))){
          if (tally[[part]][2] > 0) {
            censor_contacts_out <- append(censor_contacts_out, TRUE)
            tally[[part]][2] <- tally[[part]][2] - 1
          } else {
            censor_contacts_out <- append(censor_contacts_out, FALSE)
          }
            
          
        } else {
          
          if(c$cnt_age_est_min == '0'){
            if(c['cnt_work'] == TRUE){
              if (tally[[part]][3] > 0) {
                censor_contacts_out <- append(censor_contacts_out, TRUE)
                tally[[part]][3] <- tally[[part]][3] - 1
              } else {
                censor_contacts_out <- append(censor_contacts_out, FALSE)
              }
            } else if(c['cnt_school'] == TRUE){
              if (tally[[part]][4] > 0) {
                censor_contacts_out <- append(censor_contacts_out, TRUE)
                tally[[part]][4] <- tally[[part]][4] - 1
              } else {
                censor_contacts_out <- append(censor_contacts_out, FALSE)
              }
            } else {
              if (tally[[part]][5] > 0) {
                censor_contacts_out <- append(censor_contacts_out, TRUE)
                tally[[part]][5] <- tally[[part]][5] - 1
              } else {
                censor_contacts_out <- append(censor_contacts_out, FALSE)
              }
            }
          } else if(c['cnt_age_est_min'] == '18'){
            if(c['cnt_work'] == TRUE){
              if (tally[[part]][6] > 0) {
                censor_contacts_out <- append(censor_contacts_out, TRUE)
                tally[[part]][6] <- tally[[part]][6] - 1
              } else {
                censor_contacts_out <- append(censor_contacts_out, FALSE)
              }
            } else if(c['cnt_school'] == TRUE){
              if (tally[[part]][7] > 0) {
                censor_contacts_out <- append(censor_contacts_out, TRUE)
                tally[[part]][7] <- tally[[part]][7] - 1
              } else {
                censor_contacts_out <- append(censor_contacts_out, FALSE)
              }
            } else {
              if (tally[[part]][8] > 0) {
                censor_contacts_out <- append(censor_contacts_out, TRUE)
                tally[[part]][8] <- tally[[part]][8] - 1
              } else {
                censor_contacts_out <- append(censor_contacts_out, FALSE)
              }
            }
          } else {
            if(c['cnt_work'] == TRUE){
              if (tally[[part]][9] > 0) {
                censor_contacts_out <- append(censor_contacts_out, TRUE)
                tally[[part]][9] <- tally[[part]][9] - 1
              } else {
                censor_contacts_out <- append(censor_contacts_out, FALSE)
              }
            } else if(c['cnt_school'] == TRUE){
              if (tally[[part]][10] > 0) {
                censor_contacts_out <- append(censor_contacts_out, TRUE)
                tally[[part]][10] <- tally[[part]][10] - 1
              } else {
                censor_contacts_out <- append(censor_contacts_out, FALSE)
              }
            } else {
              if (tally[[part]][11] > 0) {
                censor_contacts_out <- append(censor_contacts_out, TRUE)
                tally[[part]][11] <- tally[[part]][11] - 1
              } else {
                censor_contacts_out <- append(censor_contacts_out, FALSE)
              }
            }
          }
          
        }
          
          
      } else {
          if (tally[[part]][12] > 0) {
            censor_contacts_out <- append(censor_contacts_out, TRUE)
            tally[[part]][12] <- tally[[part]][12] - 1
          } else {
            censor_contacts_out <- append(censor_contacts_out, FALSE)
          }
        }
      
    } else {
      censor_contacts_out <- append(censor_contacts_out, TRUE)
    }
    
  }
  return(censor_contacts_out)
}



# Assign exact age to participants/contacts using sampling technique
processSurvey <- function(in_dir,out_dir,country, year){
  
  files <- list.files(in_dir, full.names = TRUE)
  
  survey_files <- grep("csv$", files, value = TRUE)
  
  participants_dir <- grep(paste0("_", "participant", "_common.*\\.csv$"), survey_files, value = TRUE)
  contacts_dir <- grep(paste0("_", "contact", "_common.*\\.csv$"), survey_files, value = TRUE)
  
  # Read in csv files and convert to dataframe
  participants <- read.csv(participants_dir)
  contacts <- read.csv(contacts_dir)
  
  age_dist <- wpp_age(country, as.integer(year))

  age_list <- c(seq(2,97,5), 100)
  age_whole <- c()
  
  for(age in seq(1,length(age_list))){
    age_whole <- append(age_whole, rep(age_list[age],age_dist$population[age]))
  }
  
  dens <- density(x=age_whole, kernel='gaussian', bw=3, n=131, from=0, to=130)

  # Sample participant and contact ages 
  participants$part_age <- apply(participants,1,participant_resample,dens=dens$y)
  
  contacts$cnt_age_exact <- apply(contacts,1,contact_resample,dens=dens$y)
  
  # Check if CoMix
  if (grepl("(C)",in_dir, ignore.case = FALSE, fixed =TRUE)){
    # Define table for high contact individuals
    part_exc <- table(contacts$part_id) < 50
    
    # Check if high contact (>50 contacts) participant, assign true/false 
    contacts$cnt_small <- apply(contacts,1,big_contact_checker,exc=part_exc)
    
    # Define proportional contacts for each high contact participant
    contact_lookup <- group_contact_distribution(contacts)
    contact_lookup <- rescale_contacts(contact_lookup)
    
    # for each high contact, sample 50 contacts 
    contacts$cnt_large_inc <- censor_contacts(contacts,contact_lookup)
    
  }
  
  
  # Save with sampled ages
  write.csv(x=participants, file= gsub(pattern = "/Raw/", replacement = '/Processed/', x = participants_dir), row.names=FALSE)
  write.csv(x=contacts, file= gsub(pattern = "/Raw/", replacement = '/Processed/', x = contacts_dir), row.names=FALSE)
}


# Process each survey from surveys vector
sampleSurveys <- function(surveys){
  for (i in seq(1,length(surveys))){
    print(surveys[[i]][1])
    processSurvey(surveys[[i]][2],surveys[[i]][3], surveys[[i]][1], surveys[[i]][4])
  }
}

surveys <- list(
  #CoMix
  c('Austria', 'Data/Austria (C)/Raw', 'Data/Austria (C)/Processed', 2021, NA),
  c('Croatia', 'Data/Croatia (C)/Raw', 'Data/Croatia (C)/Processed', 2021, NA),
  c('Denmark', 'Data/Denmark (C)/Raw', 'Data/Denmark (C)/Processed', 2021, NA),
  c('Estonia', 'Data/Estonia (C)/Raw', 'Data/Estonia (C)/Processed', 2021, NA),
  c('Finland', 'Data/Finland (C)/Raw', 'Data/Finland (C)/Processed', 2021, NA),
  c('France', 'Data/France (C)/Raw', 'Data/France (C)/Processed', 2021, NA),
  c('Greece', 'Data/Greece (C)/Raw', 'Data/Greece (C)/Processed', 2021, NA),
  c('Hungary', 'Data/Hungary (C)/Raw', 'Data/Hungary (C)/Processed', 2021, NA),
  c('Italy', 'Data/Italy (C)/Raw', 'Data/Italy (C)/Processed', 2021, NA),
  c('Lithuania', 'Data/Lithuania (C)/Raw', 'Data/Lithuania (C)/Processed', 2021, NA),
  c('Netherlands', 'Data/Netherlands (C)/Raw', 'Data/Netherlands (C)/Processed', 2021, NA),
  c('Poland', 'Data/Poland (C)/Raw', 'Data/Poland (C)/Processed', 2021, NA),
  c('Portugal', 'Data/Portugal (C)/Raw', 'Data/Portugal (C)/Processed', 2021, NA),
  c('Slovakia', 'Data/Slovakia (C)/Raw', 'Data/Slovakia (C)/Processed', 2021, NA),
  c('Slovenia', 'Data/Slovenia (C)/Raw', 'Data/Slovenia (C)/Processed', 2021, NA),
  c('Spain', 'Data/Spain (C)/Raw', 'Data/Spain (C)/Processed', 2021, NA),
  c('Switzerland', 'Data/Switzerland (C)/Raw', 'Data/Switzerland (C)/Processed', 2021, NA),
  c('UK', 'Data/United Kingdom (C)/Raw', 'Data/United Kingdom (C)/Processed', 2021, NA),
  # Other
  c('Belgium', 'Data/Belgium, 2006/Raw', 'Data/Belgium, 2006/Processed', 2006, NA),
  c('Belgium', 'Data/Belgium, 2010/Raw', 'Data/Belgium, 2010/Processed', 2010, NA),
  c('China', 'Data/China, 2019/Raw', 'Data/China, 2019/Processed', 2019, 1),
  c('China', 'Data/China, 2020/Raw', 'Data/China, 2020/Processed', 2020, NA),
  c('China', 'Data/China, 2020/Filtered/Shanghai_outbreak/Raw', 'Data/China, 2020/Filtered/Shanghai_outbreak/Processed', 2020, 1),
  c('China', 'Data/China, 2020/Filtered/Wuhan_baseline/Raw', 'Data/China, 2020/Filtered/Wuhan_baseline/Processed', 2019, 2),
  c('China', 'Data/China, 2020/Filtered/Wuhan_outbreak/Raw', 'Data/China, 2020/Filtered/Wuhan_outbreak/Processed', 2020, 2),
  c('France', 'Data/France/Raw', 'Data/France/Processed', 2012, NA),
  c('Hong Kong', 'Data/Hong Kong/Raw', 'Data/Hong Kong/Processed', 2016, NA),
  c('Peru', 'Data/Peru/Raw', 'Data/Peru/Processed', 2011, 3),
  c('Vietnam', 'Data/Vietnam/Raw', 'Data/Vietnam/Processed', 2011, NA),
  c('Zimbabwe', 'Data/Zimbabwe/Raw', 'Data/Zimbabwe/Processed', 2013, NA),
  c('Zimbabwe', 'Data/Zimbabwe/Filtered/Peri_urban/Raw', 'Data/Zimbabwe/Filtered/Peri_urban/Processed', 2013, 4),
  c('Zimbabwe', 'Data/Zimbabwe/Filtered/Farm/Raw', 'Data/Zimbabwe/Filtered/Farm/Processed', 2013, 5)
)


sampleSurveys(surveys)

