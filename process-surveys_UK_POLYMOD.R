# Script for pre-processing UK POLYMOD contact survey

library(socialmixr)
library(hash)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

age_range <- c(2,7,12,17,22,27,32,37,42,47,52,57,62)

comix_ages_parts <- c(0,5,12,18,30,40,50,60,70,130)
comix_ages_hh <- c(0,1,5,12,16,18,20,25,35,45,55,65,70,75,80,85,130)

parent_contact_age_density <- read.csv('Output/Age densities/UK_parent_age_density.csv')
child_contact_age_density <- read.csv('Output/Age densities/UK_child_age_density.csv')

part_child_lower_age_map <- c(rep(15,5), rep(20,5), rep(25,5), rep(30,5))
part_child_upper_age_map <- c(rep(49,5), rep(54,5), rep(59,5), rep(64,5))

part_parent_lower_age_map <- c(rep(0,5), rep(0,5), rep(0,5), rep(0,5),
                               rep(0,5), rep(0,5), rep(0,5), rep(5,5),
                               rep(10,5), rep(15,5))
part_parent_upper_age_map <- c(rep(4,5), rep(9,5), rep(14,5), rep(19,5),
                               rep(19,5), rep(19,5), rep(19,5), rep(19,5),
                               rep(19,5), rep(19,5))

age_density_child <- matrix(nrow=20,ncol=13)
age_density_parent <- matrix(nrow=65,ncol=13)
s
child_age_map <- c(rep('0-4',5),rep('5-9',5),rep('10-14',5),rep('15-19',5))
parent_age_map <- c(rep('15-19',5),rep('20-24',5),rep('25-29',5),rep('30-34',5),
                    rep('35-39',5),rep('40-44',5),rep('45-49',5),rep('50-54',5),
                    rep('55-59',5),rep('60-64',5))


# build age_density
for (a in 0:19){
  temp <- c(rep(0,3 + as.integer(a / 5)))
  temp <- append(temp,parent_contact_age_density[which(parent_contact_age_density$Survey.year == '2021 (CoMix)' &
                                          parent_contact_age_density$Data.Source == 'ONS' &
                                          parent_contact_age_density$Child.age == child_age_map[a+1]),]$Estimated.proportion.of.parents)
  length(temp) = 13
  temp[is.na(temp)] <- 0
  age_density_child[a+1,] <- temp
  age_density_parent[a+1,] <- 0
}

for (a in 15:64){
  temp <- c()
  temp <- append(temp,child_contact_age_density[which(child_contact_age_density$Survey.year == '2021 (CoMix)' &
                                                        child_contact_age_density$Parent.age == parent_age_map[a+1 - 15]),]$Estimated.proportion.of.children
  )
  length(temp) = 13
  temp[is.na(temp)] <- 0
  age_density_parent[a+1,] <- temp
}

# Sample participant age from bounds based on density 
participant_resample <- function(p, dens = NULL){
  age <- p['part_age']
  new_part_age <- as.integer(age)
  
  if (!is.na(age)){
    
    # Sample age of household contact based on CoMix age bracketing
    lower <- -1
    upper <- -1
    j <- 0
    
    while(new_part_age > upper){
      lower <- comix_ages_parts[j+1]
      upper <- comix_ages_parts[j+2] - 1
      j <- j + 1
    }
    
    if (lower == upper){
      new_part_age <- lower
    } else {
      new_part_age <- sample(seq(lower,upper),prob=dens[(lower+1):(upper+1)],size=1)
    }
    print('PART:')
    print(as.integer(age))
    print(new_part_age)
    print('---')
  }
  
  return(new_part_age)
}

# Sample contact age from bounds based on density
contact_resample <- function(c, part_lookup, dens = NULL){
  
  contact_age <- as.integer(c['cnt_age_exact'])
  new_contact_age <- contact_age
  
  household <- as.character(c['cnt_home'])
  school <- as.character(c['cnt_school'])
  work <- as.character(c['cnt_work'])
  
  if (!is.na(household) && (household == 'TRUE') && !is.na(school) && (school == 'FALSE') &&
      !is.na(work) && (work == 'FALSE')){
    part_id <- as.character(as.integer(c['part_id']))
    part_age <- as.integer(part_lookup[[part_id]])
    

    if (!is.na(part_age) && !is.na(contact_age)){

    # Sample age of child based on parental age distribution (comment out below if statement if just applying comix age bracketing)
    if (part_age < 20 &&
        (contact_age > part_child_lower_age_map[part_age + 1]) &&
        (contact_age < part_child_upper_age_map[part_age + 1])){

      new_contact_age <- sample(age_range,prob=age_density_child[part_age+1,],size=1)

      print(contact_age)
      print(part_age)
      print(new_contact_age)
      # print('---')
    }

    # Sample age of parent based on parental age distribution (comment out below if statement if just applying comix age bracketing)
    if (part_age > 15 && part_age < 65 &&
        (contact_age > part_parent_lower_age_map[part_age - 15]) &&
        (contact_age < part_parent_upper_age_map[part_age - 15])){


      new_contact_age <- sample(age_range,prob=age_density_parent[part_age+1,],size=1)

      print(contact_age)
      print(part_age)
      print(new_contact_age)
    print('---')
    }
    
    
    # Sample age of household contact based on CoMix age bracketing
    lower <- -1
    upper <- -1
    j <- 0

    while(new_contact_age > upper){
      lower <- comix_ages_hh[j+1]
      upper <- comix_ages_hh[j+2] - 1
      j <- j + 1
    }

    if (lower == upper){
      new_contact_age <- lower
    } else {
      new_contact_age <- sample(seq(lower,upper),prob=dens[(lower+1):(upper+1)],size=1)
    }

    print('CONTACT:')
    print(contact_age)
    print(new_contact_age)
    print('---')
    }
  }
  
  return(new_contact_age)
}

# Assign exact age to participants/contacts using sampling technique
participants_dir <- 'Data/POLYMOD/2008_Mossong_POLYMOD_participant_common.csv'
participants_extra_dir <- 'Data/POLYMOD/2008_Mossong_POLYMOD_participant_extra.csv'
contacts_dir <- 'Data/POLYMOD/2008_Mossong_POLYMOD_contact_common.csv'

# Read in csv files and convert to dataframe
participants <- read.csv(participants_dir)
participants_extra <- read.csv(participants_extra_dir)
contacts <- read.csv(contacts_dir)
  

# Define participant look-up - participant id -> participant age bracket
part_lookup_uk <- hash(as.character(participants$part_id), participants$part_age)

# Filter participants and contacts for UK only
part_lookup_nationality <- hash(as.character(participants_extra$part_id), participants_extra$participant_nationality)


for(a in ls(part_lookup_uk)){
  if (part_lookup_nationality[[a]] != 'UK'){
    
    part_lookup_uk[[a]] <- NA
  } else{
    print(a)
  }
}

age_dist <- wpp_age('United Kingdom', 2005)

age_list <- c(seq(2,97,5), 100)
age_whole <- c()

for(age in seq(1,length(age_list))){
  age_whole <- append(age_whole, rep(age_list[age],age_dist$population[age]))
}

dens <- density(x=age_whole, kernel='gaussian', bw=3, n=131, from=0, to=130)

# Number of sample repetitons
N <- 50

for (i in 1:N){
  participants_temp <- participants
  contacts_temp <- contacts
  
  participants_temp$part_age <- apply(participants_temp,1,participant_resample,dens=dens$y)
  contacts_temp$cnt_age_exact <- apply(contacts_temp,1,contact_resample,part_lookup=part_lookup_uk, dens=dens$y)
  
  # Save with sampled ages
  write.csv(x=participants_temp, file=paste('Data/POLYMOD/Processed/Blurred/',as.character(i),'/2008_Mossong_POLYMOD_participant_common.csv'), row.names=FALSE)
  write.csv(x=contacts_temp, file=paste('Data/POLYMOD/Processed/Blurred/',as.character(i),'/2008_Mossong_POLYMOD_contact_common.csv'), row.names=FALSE)
  
}

age_grouping <- seq(0,70,5)

for (i in 1:N){
  
  # file_list <- list.files('Data/POLYMOD',full.names = TRUE)
  # 
  # file_list <- append(file_list, paste('Data/POLYMOD/Processed/Blurred/',as.character(i),'/2008_Mossong_POLYMOD_participant_common.csv'))
  # 
  # file_list <- append(file_list, paste('Data/POLYMOD/Processed/Blurred/',as.character(i),'/2008_Mossong_POLYMOD_contact_common.csv'))
  
  # file_list <- append(list.files(paste0('Data/POLYMOD/Processed/Blurred/',as.character(i)),full.names = TRUE),
  # setdiff(list.files('Data/POLYMOD',full.names = TRUE), list.dirs('Data/POLYMOD/Processed',recursive = FALSE, full.names = TRUE)))
  
  file_list <- c(
    "Data/POLYMOD/2008_Mossong_POLYMOD_dictionary.xls",
    "Data/POLYMOD/2008_Mossong_POLYMOD_hh_common.csv",
    "Data/POLYMOD/2008_Mossong_POLYMOD_hh_extra.csv",
    "Data/POLYMOD/2008_Mossong_POLYMOD_participant_extra.csv",
    "Data/POLYMOD/2008_Mossong_POLYMOD_sday.csv",
    "Data/POLYMOD/comix_nl_reference.json",
    paste0('Data/POLYMOD/Processed/Blurred/ ',as.character(i),' /2008_Mossong_POLYMOD_contact_common.csv'),
    paste0('Data/POLYMOD/Processed/Blurred/ ',as.character(i),' /2008_Mossong_POLYMOD_participant_common.csv')
  )
  
  print(file_list)
  
  polymod_processed <- load_survey(file_list)
  
  
  # Overall
  cm_polymod_overall_processed <- contact_matrix(survey=polymod_processed,
                                       countries='United Kingdom',
                                       age.limits=age_grouping,
                                       filter = list(cnt_home = 1),
                                       symmetric = TRUE,
                                       weigh.age = TRUE,
                                       per.capita = TRUE)

  
  if (i == 1){
    poly_cm_overall_processed <- cm_polymod_overall_processed$matrix.per.capita / sum(cm_polymod_overall_processed$matrix.per.capita)
  } else{
    poly_cm_overall_processed <- poly_cm_overall_processed + (cm_polymod_overall_processed$matrix.per.capita / sum(cm_polymod_overall_processed$matrix.per.capita))
  }
  
  
  
}

output_cm <- poly_cm_overall_processed / N

rownames(output_cm) <- colnames(output_cm)
# write.table(output_cm, "Output/UK case study/polymod_comix_c.csv", sep = '\t')
write.table(output_cm, "Output/UK case study/polymod_full_cd.csv", sep = '\t')

