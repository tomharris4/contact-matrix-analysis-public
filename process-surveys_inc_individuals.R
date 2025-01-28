# Script for pre-processing contact surveys 

library(socialmixr)
library(hash)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


# Sample contact age from bounds based on density
contact_ind_checker <- function(c, dens = NULL){
  # check if individual contact
  if(!is.na(c['cnt_age_exact']) & (!is.na(c['cnt_gender']) | !is.na(c['frequency_multi']))){
    return(TRUE)
  }
  return(FALSE)
}

# Assign exact age to participants/contacts using sampling technique
processSurvey <- function(in_dir,out_dir,country, year){
  
  files <- list.files(in_dir, full.names = TRUE)
  
  survey_files <- grep("csv$", files, value = TRUE)
  
  contacts_dir <- grep(paste0("_", "contact", "_common.*\\.csv$"), survey_files, value = TRUE)
  
  contacts_csv <- read.csv(contacts_dir)

  contacts_csv$cnt_ind <- apply(contacts_csv,1,contact_ind_checker)

  write.csv(x=contacts_csv, file= contacts_dir, row.names=FALSE)
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
  c('Austria', 'Data/Austria (C)/Processed', 'Data/Austria (C)/Processed', 2021, NA),
  c('Croatia', 'Data/Croatia (C)/Processed', 'Data/Croatia (C)/Processed', 2021, NA),
  c('Denmark', 'Data/Denmark (C)/Processed', 'Data/Denmark (C)/Processed', 2021, NA),
  c('Estonia', 'Data/Estonia (C)/Processed', 'Data/Estonia (C)/Processed', 2021, NA),
  c('Finland', 'Data/Finland (C)/Processed', 'Data/Finland (C)/Processed', 2021, NA),
  c('France', 'Data/France (C)/Processed', 'Data/France (C)/Processed', 2021, NA),
  c('Greece', 'Data/Greece (C)/Processed', 'Data/Greece (C)/Processed', 2021, NA),
  c('Hungary', 'Data/Hungary (C)/Processed', 'Data/Hungary (C)/Processed', 2021, NA),
  c('Italy', 'Data/Italy (C)/Processed', 'Data/Italy (C)/Processed', 2021, NA),
  c('Lithuania', 'Data/Lithuania (C)/Processed', 'Data/Lithuania (C)/Processed', 2021, NA),
  c('Netherlands', 'Data/Netherlands (C)/Processed', 'Data/Netherlands (C)/Processed', 2021, NA),
  # c('Poland', 'Data/Poland (C)/Processed', 'Data/Poland (C)/Processed', 2021, NA),
  c('Portugal', 'Data/Portugal (C)/Processed', 'Data/Portugal (C)/Processed', 2021, NA),
  c('Slovakia', 'Data/Slovakia (C)/Processed', 'Data/Slovakia (C)/Processed', 2021, NA),
  c('Slovenia', 'Data/Slovenia (C)/Processed', 'Data/Slovenia (C)/Processed', 2021, NA),
  c('Spain', 'Data/Spain (C)/Processed', 'Data/Spain (C)/Processed', 2021, NA),
  c('Switzerland', 'Data/Switzerland (C)/Processed', 'Data/Switzerland (C)/Processed', 2021, NA),
  c('UK', 'Data/United Kingdom (C)/Processed', 'Data/United Kingdom (C)/Processed', 2021, NA)
)


sampleSurveys(surveys)

