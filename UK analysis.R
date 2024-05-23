library(socialmixr)
library(deSolve)
library(kknn)
library(philentropy)
library(ggplot2)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Contact matrix age groupings - 5 year bands between 0 and 70
age_grouping <- seq(0,70,5)


# Check if contact is individual or group using lower and upper age bounds
contact_ind_checker <- function(c) {

  lower <- as.integer(c['cnt_age_est_min'])
  upper <- as.integer(c['cnt_age_est_max'])

  if (!is.na(lower) & !is.na(upper)){

    lower <- as.integer(c['cnt_age_est_min'])
    upper <- as.integer(c['cnt_age_est_max'])

    if (lower == 0 & upper == 17){
      return(FALSE)
    }

    if (lower == 18 & upper == 64){
      return(FALSE)
    }

    if (lower == 65 & upper == 100){
      return(FALSE)
    }
    }

  return(TRUE)
}

# Build contact matrices for POLYMOD survey filtered on location
# Overall
cm_polymod <- contact_matrix(survey=polymod,
                     countries='United Kingdom',
                     age.limits=age_grouping,
                     symmetric = TRUE,
                     weigh.age = TRUE,
                     per.capita = TRUE)

poly_cm_overall <- cm_polymod$matrix.per.capita / sum(cm_polymod$matrix.per.capita)

# Household
cm_polymod <- contact_matrix(survey=polymod,
                             countries='United Kingdom',
                             age.limits=age_grouping,
                             filter = list(cnt_home = 1),
                             symmetric = TRUE,
                             weigh.age = TRUE,
                             per.capita = TRUE)

poly_cm_household <- cm_polymod$matrix.per.capita / sum(cm_polymod$matrix.per.capita)

# Workplace
cm_polymod <- contact_matrix(survey=polymod,
                             countries='United Kingdom',
                             age.limits=age_grouping,
                             filter = list(cnt_work = 1),
                             symmetric = TRUE,
                             weigh.age = TRUE,
                             per.capita = TRUE)

poly_cm_work <- cm_polymod$matrix.per.capita / sum(cm_polymod$matrix.per.capita)

# School
cm_polymod <- contact_matrix(survey=polymod,
                             countries='United Kingdom',
                             age.limits=age_grouping,
                             filter = list(cnt_school = 1),
                             symmetric = TRUE,
                             weigh.age = TRUE,
                             per.capita = TRUE)

poly_cm_school <- cm_polymod$matrix.per.capita / sum(cm_polymod$matrix.per.capita)


# Read in processed CoMix survey
file_list <- append(list.files(paste0('Data/United Kingdom (C)','/Processed'),full.names = TRUE),
                    setdiff(list.files('Data/United Kingdom (C)',full.names = TRUE), list.dirs('Data/United Kingdom (C)',recursive = FALSE, full.names = TRUE))
)

# Run below 3 lines to append individual/group contact marker to survey csv file
# contacts_csv <- read.csv(file_list[1])
# 
# contacts_csv$cnt_ind <- apply(contacts_csv,1,contact_ind_checker)
# 
# write.csv(x=contacts_csv, file= file_list[1], row.names=FALSE)


# Load survey into socialmixr survey object
comix_processed <- load_survey(file_list)

# Add 2000 years to account for error in survey recording error
comix_processed$participants$year <- comix_processed$participants$year + 2000

# Build contact matrices for CoMix survey filtered on location
# Overall
cm_comix_processed <- contact_matrix(survey=comix_processed,
                               countries='United Kingdom',
                               age.limits= age_grouping,
                               filter = list(cnt_large_inc = 1),
                               symmetric = TRUE,
                               weigh.age = TRUE,
                               per.capita = TRUE)

comix_cm_processed_overall <- cm_comix_processed$matrix.per.capita / sum(cm_comix_processed$matrix.per.capita)

# Household
cm_comix_processed <- contact_matrix(survey=comix_processed,
                                     countries='United Kingdom',
                                     age.limits= age_grouping,
                                     filter = list(cnt_large_inc = 1, cnt_home = 1),
                                     symmetric = TRUE,
                                     weigh.age = TRUE,
                                     per.capita = TRUE)

comix_cm_processed_household <- cm_comix_processed$matrix.per.capita / sum(cm_comix_processed$matrix.per.capita)

# Workplace
cm_comix_processed <- contact_matrix(survey=comix_processed,
                                     countries='United Kingdom',
                                     age.limits= age_grouping,
                                     filter = list(cnt_large_inc = 1, cnt_work = 1),
                                     symmetric = TRUE,
                                     weigh.age = TRUE,
                                     per.capita = TRUE)

comix_cm_processed_work <- cm_comix_processed$matrix.per.capita / sum(cm_comix_processed$matrix.per.capita)

# School
cm_comix_processed <- contact_matrix(survey=comix_processed,
                                     countries='United Kingdom',
                                     age.limits= age_grouping,
                                     filter = list(cnt_large_inc = 1, cnt_school = 1),
                                     symmetric = TRUE,
                                     weigh.age = TRUE,
                                     per.capita = TRUE)

comix_cm_processed_school <- cm_comix_processed$matrix.per.capita / sum(cm_comix_processed$matrix.per.capita)


# Build contact matrices for CoMix survey filtered on location and individual/group contact types
# Overall - individual
cm_comix_processed <- contact_matrix(survey=comix_processed,
                                     countries='United Kingdom',
                                     age.limits= age_grouping,
                                     filter = list(cnt_large_inc = 1, cnt_ind = 1),
                                     symmetric = TRUE,
                                     weigh.age = TRUE,
                                     per.capita = TRUE)

comix_cm_processed_ind <- cm_comix_processed$matrix.per.capita / sum(cm_comix_processed$matrix.per.capita)

# Overall - group
cm_comix_processed <- contact_matrix(survey=comix_processed,
                                     countries='United Kingdom',
                                     age.limits= age_grouping,
                                     filter = list(cnt_large_inc = 1, cnt_ind = 0),
                                     symmetric = TRUE,
                                     weigh.age = TRUE,
                                     per.capita = TRUE)

comix_cm_processed_group <- cm_comix_processed$matrix.per.capita / sum(cm_comix_processed$matrix.per.capita)

# School - individual
cm_comix_processed <- contact_matrix(survey=comix_processed,
                                     countries='United Kingdom',
                                     age.limits= age_grouping,
                                     filter = list(cnt_large_inc = 1, cnt_ind = 1, cnt_school = 1),
                                     symmetric = TRUE,
                                     weigh.age = TRUE,
                                     per.capita = TRUE)

comix_cm_processed_ind_school <- cm_comix_processed$matrix.per.capita / sum(cm_comix_processed$matrix.per.capita)

# School - group
cm_comix_processed <- contact_matrix(survey=comix_processed,
                                     countries='United Kingdom',
                                     age.limits= age_grouping,
                                     filter = list(cnt_large_inc = 1, cnt_ind = 0, cnt_school = 1),
                                     symmetric = TRUE,
                                     weigh.age = TRUE,
                                     per.capita = TRUE)

comix_cm_processed_group_school <- cm_comix_processed$matrix.per.capita / sum(cm_comix_processed$matrix.per.capita)

# Workplace - individual
cm_comix_processed <- contact_matrix(survey=comix_processed,
                                     countries='United Kingdom',
                                     age.limits= age_grouping,
                                     filter = list(cnt_large_inc = 1, cnt_ind = 1, cnt_work = 1),
                                     symmetric = TRUE,
                                     weigh.age = TRUE,
                                     per.capita = TRUE)
                                     # counts = TRUE)

comix_cm_processed_ind_work <- cm_comix_processed$matrix.per.capita / sum(cm_comix_processed$matrix.per.capita)

# Workplace - group
cm_comix_processed <- contact_matrix(survey=comix_processed,
                                     countries='United Kingdom',
                                     age.limits= age_grouping,
                                     filter = list(cnt_large_inc = 1, cnt_ind = 0, cnt_work = 1),
                                     symmetric = TRUE,
                                     weigh.age = TRUE,
                                     per.capita = TRUE)
                                     # counts = TRUE)

comix_cm_processed_group_work <- cm_comix_processed$matrix.per.capita / sum(cm_comix_processed$matrix.per.capita)



# Read in processed CoMix survey filtered on intervention stringency
# NOTE: change string 'Strongest' to process other intervention stringencies (e.g. 'Weak')
file_list <- append(list.files(paste0('Data/United Kingdom (C)','/Filtered/Strongest'),full.names = TRUE),
                    setdiff(list.files('Data/United Kingdom (C)',full.names = TRUE), list.dirs('Data/United Kingdom (C)',recursive = FALSE, full.names = TRUE))
)

# Load survey into socialmixr survey object
comix_processed <- load_survey(file_list)

# Add 2000 years to account for error in survey recording error
comix_processed$participants$year <- comix_processed$participants$year + 2000

# Build contact matrices for CoMix survey filtered on location and stringency
# Overall
cm_comix_processed <- contact_matrix(survey=comix_processed,
                                     countries='United Kingdom',
                                     age.limits= age_grouping,#c(0,5,12,18,20,25,30,35,40,45,50,55,60,65,70),
                                     filter = list(cnt_large_inc = 1),
                                     symmetric = TRUE,
                                     weigh.age = TRUE,
                                     per.capita = TRUE)

comix_cm_processed_overall <- cm_comix_processed$matrix.per.capita / sum(cm_comix_processed$matrix.per.capita)

# Household
cm_comix_processed <- contact_matrix(survey=comix_processed,
                                     countries='United Kingdom',
                                     age.limits= age_grouping,
                                     filter = list(cnt_large_inc = 1, cnt_home = 1),
                                     symmetric = TRUE,
                                     weigh.age = TRUE,
                                     per.capita = TRUE)

comix_cm_processed_household <- cm_comix_processed$matrix.per.capita / sum(cm_comix_processed$matrix.per.capita)

# School
cm_comix_processed <- contact_matrix(survey=comix_processed,
                                     countries='United Kingdom',
                                     age.limits= age_grouping,
                                     filter = list(cnt_large_inc = 1, cnt_school = 1),
                                     symmetric = TRUE,
                                     weigh.age = TRUE,
                                     per.capita = TRUE)

comix_cm_processed_school <- cm_comix_processed$matrix.per.capita / sum(cm_comix_processed$matrix.per.capita)

# Workplace
cm_comix_processed <- contact_matrix(survey=comix_processed,
                                     countries='United Kingdom',
                                     age.limits= age_grouping,
                                     filter = list(cnt_large_inc = 1, cnt_work = 1),
                                     symmetric = TRUE,
                                     weigh.age = TRUE,
                                     per.capita = TRUE)

comix_cm_processed_work <- cm_comix_processed$matrix.per.capita / sum(cm_comix_processed$matrix.per.capita)


# MATRIX OUTPUT - WRITE ALL CONTACT MATRICES TO CSV FILES

# rownames(comix_cm_processed_overall) <- colnames(comix_cm_processed_overall)
# write.table(comix_cm_processed_overall, "UK processed contact matrices/comix_overall_strongest.csv", sep = '\t')
# 
# 
# rownames(comix_cm_processed_household) <- colnames(comix_cm_processed_household)
# write.table(comix_cm_processed_household, "UK processed contact matrices/comix_household_strongest.csv", sep = '\t')
# 
# 
# rownames(comix_cm_processed_school) <- colnames(comix_cm_processed_school)
# write.table(comix_cm_processed_school, "UK processed contact matrices/comix_school_strongest.csv", sep = '\t')
# 
# 
# rownames(comix_cm_processed_work) <- colnames(comix_cm_processed_work)
# write.table(comix_cm_processed_work, "UK processed contact matrices/comix_work_strongest.csv", sep = '\t')
# 
# 
# rownames(poly_cm_overall) <- colnames(poly_cm_overall)
# write.table(poly_cm_overall, "UK processed contact matrices/polymod_overall.csv", sep = '\t')
# 
# rownames(poly_cm_household) <- colnames(poly_cm_household)
# write.table(poly_cm_household, "UK processed contact matrices/polymod_household.csv", sep = '\t')
# 
# rownames(poly_cm_school) <- colnames(poly_cm_school)
# write.table(poly_cm_school, "UK processed contact matrices/polymod_school.csv", sep = '\t')
# 
# rownames(poly_cm_work) <- colnames(poly_cm_work)
# write.table(poly_cm_work, "UK processed contact matrices/polymod_work.csv", sep = '\t')
# 
# rownames(comix_cm_processed_overall) <- colnames(comix_cm_processed_overall)
# write.table(comix_cm_processed_overall, "UK processed contact matrices/comix_overall.csv", sep = '\t')
# 
# rownames(comix_cm_processed_household) <- colnames(comix_cm_processed_household)
# write.table(comix_cm_processed_household, "UK processed contact matrices/comix_household.csv", sep = '\t')
# 
# rownames(comix_cm_processed_school) <- colnames(comix_cm_processed_school)
# write.table(comix_cm_processed_school, "UK processed contact matrices/comix_school.csv", sep = '\t')
# 
# rownames(comix_cm_processed_work) <- colnames(comix_cm_processed_work)
# write.table(comix_cm_processed_work, "UK processed contact matrices/comix_work.csv", sep = '\t')
# 
# rownames(comix_cm_processed_ind) <- colnames(comix_cm_processed_ind)
# write.table(comix_cm_processed_ind, "UK processed contact matrices/comix_ind.csv", sep = '\t')
# 
# rownames(comix_cm_processed_group) <- colnames(comix_cm_processed_group)
# write.table(comix_cm_processed_group, "UK processed contact matrices/comix_group.csv", sep = '\t')
# 
# rownames(comix_cm_processed_ind_school) <- colnames(comix_cm_processed_ind_school)
# write.table(comix_cm_processed_ind_school, "UK processed contact matrices/comix_ind_school.csv", sep = '\t')
# 
# rownames(comix_cm_processed_group_school) <- colnames(comix_cm_processed_group_school)
# write.table(comix_cm_processed_group_school, "UK processed contact matrices/comix_group_school.csv", sep = '\t')
# 
# rownames(comix_cm_processed_ind_work) <- colnames(comix_cm_processed_ind_work)
# write.table(comix_cm_processed_ind_work, "UK processed contact matrices/comix_ind_work.csv", sep = '\t')
# 
# rownames(comix_cm_processed_group_work) <- colnames(comix_cm_processed_group_work)
# write.table(comix_cm_processed_group_work, "UK processed contact matrices/comix_group_work.csv", sep = '\t')

