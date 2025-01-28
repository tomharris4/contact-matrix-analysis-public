library(socialmixr)
library(deSolve)
library(kknn)
library(philentropy)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load in all non-national age demographics 
load('Data/China, 2020/Shanghai_demographics.Rda')
load('Data/China, 2020/Wuhan_demographics.Rda')
load('Data/Peru/Peru_demographics.Rda')
load('Data/Zimbabwe/Peri_urban_demographics.Rda')
load('Data/Zimbabwe/Farm_demographics.Rda')

demos <- list(shanghai_demo,wuhan_demo, peru_demo, peri_urban_demo, farm_demo)



# PULL IN ALL NON-POLYMOD CONTACT SURVEYS SAVED LOCALLY

surveys <- list(
  # CoMix
  c('Austria', 'Data/Austria (C)', 2021, NA),
  c('Croatia', 'Data/Croatia (C)', 2021, NA),
  c('Denmark', 'Data/Denmark (C)', 2021, NA),
  c('Estonia', 'Data/Estonia (C)', 2021, NA),
  c('Finland', 'Data/Finland (C)', 2021, NA),
  c('France', 'Data/France (C)', 2021, NA),
  c('Greece', 'Data/Greece (C)', 2021, NA),
  c('Hungary', 'Data/Hungary (C)', 2021, NA),
  c('Italy', 'Data/Italy (C)', 2021, NA),
  c('Lithuania', 'Data/Lithuania (C)', 2021, NA),
  c('Netherlands', 'Data/Netherlands (C)', 2021, NA),
  c('Portugal', 'Data/Portugal (C)', 2021, NA),
  c('Slovakia', 'Data/Slovakia (C)', 2021, NA),
  c('Slovenia', 'Data/Slovenia (C)', 2021, NA),
  c('Spain', 'Data/Spain (C)', 2021, NA),
  c('Switzerland', 'Data/Switzerland (C)', 2021, NA),
  c('United Kingdom', 'Data/United Kingdom (C)', 2021, NA),
  # Other
  c('Belgium', 'Data/Belgium, 2006', 2006, NA),
  c('Belgium', 'Data/Belgium, 2010', 2010, NA),
  c('China', 'Data/China, 2019', 2019, 1),
  c('China', 'Data/China, 2020/Filtered/Wuhan_baseline', 2020, 2),
  c('France', 'Data/France', 2012, NA),
  c('Hong Kong', 'Data/Hong Kong', 2016, NA),
  c('Peru', 'Data/Peru', 2011, 3 ),
  c('Zimbabwe', 'Data/Zimbabwe/Filtered/Peri_urban', 2013, 4)
)


non_polymod_contact_surveys <- list()
country_labels <- c()
country_list <- c()

for (country in 1:length(surveys)){
  
  # assemble survey file list
  country_labels <- append(country_labels, substring(surveys[[country]][2],6))
  country_list <- append(country_list, surveys[[country]][1])
  file_list <- append(list.files(paste0(surveys[[country]][2],'/Processed'),full.names = TRUE),
                      setdiff(list.files(surveys[[country]][2],full.names = TRUE), list.dirs(surveys[[country]][2],recursive = FALSE, full.names = TRUE))
  )
  
  # construct socialmixr survey object
  cs <- load_survey(files = file_list)
  
  # fix comix-uk survey year error 
  if (surveys[[country]][1] == 'United Kingdom') {
    cs$participants$year <- cs$participants$year + 2000
  }
  
  # append to surveys vector
  non_polymod_contact_surveys[[country]] <- cs
}



# DEFINE NORMAL & PER CAPITA CONTACT MATRICES - APPLY SYMMETRY CORRECTION & AGE SPECIFIC PARTICIPANT WEIGHTING

proxy_contact_matrices <- list()

set.seed(20180216)

# POLYMOD COUNTRIES

polymod_countries <- survey_countries(polymod)

for(i in 1:length(polymod_countries)){
  cm <- contact_matrix(survey=polymod,
                       countries=polymod_countries[i],
                       age.limits=seq(0,70,5),
                       symmetric = TRUE,
                       weigh.age = TRUE,
                       per.capita = TRUE)

  proxy_contact_matrices[[length(country_list) + i]] <- cm
}

# NON-POLYMOD COUNTRIES

for(i in 1:length(non_polymod_contact_surveys)){
  print(country_list[i])
  if (is.na(surveys[[i]][4])){
    # if comix, apply 50 contact limit
    if (grepl("(C)",country_labels[i], ignore.case = FALSE, fixed =TRUE)){
      cm <- contact_matrix(survey=non_polymod_contact_surveys[[i]],
                         countries=country_list[i],
                         age.limits=seq(0,70,5),
                         filter = list(cnt_large_inc = 1),
                         symmetric = TRUE, 
                         weigh.age = TRUE,
                         per.capita = TRUE)
    } else{
      cm <- contact_matrix(survey=non_polymod_contact_surveys[[i]],
                           countries=country_list[i],
                           age.limits=seq(0,70,5),
                           symmetric = TRUE, 
                           weigh.age = TRUE,
                           per.capita = TRUE)
    }
  } else{
    cm <- contact_matrix(survey=non_polymod_contact_surveys[[i]],
                         survey.pop=demos[[as.integer(surveys[[i]][4])]],
                         age.limits=seq(0,70,5),
                         symmetric = TRUE, 
                         weigh.age = TRUE,
                         per.capita = TRUE)
  }
  
  
  proxy_contact_matrices[[i]] <- cm
}

country_list <- append(country_list,polymod_countries)

# append '(P)' tag to polymod entries
for (country in polymod_countries){
  name <- paste(country,'(P)')
  country_labels <- append(country_labels, name)
}

# FIX ROW/COLUMN NAMING

apply_row_col_labels <- function(cm,row_labels,col_labels){
  
  cm_labelled <- cm
  
  rownames(cm_labelled) <- row_labels
  
  colnames(cm_labelled) <- col_labels
  
  return(cm_labelled)
}

# get age group labels from original contact matrix
age_labels <- proxy_contact_matrices[[1]]$participants$age.group 

for (cm in seq(1,length(proxy_contact_matrices))){
  proxy_contact_matrices[[cm]]$matrix <- apply_row_col_labels(proxy_contact_matrices[[cm]]$matrix,age_labels,age_labels)
  proxy_contact_matrices[[cm]]$matrix.per.capita <- apply_row_col_labels(proxy_contact_matrices[[cm]]$matrix.per.capita,age_labels,age_labels)
}

country_labels[20] <- "China (Shanghai), 2018"
country_labels[21] <- "China (Wuhan), 2019"

country_labels[22] <- "France, 2012"
country_labels[23] <- "Hong Kong, 2016"
country_labels[24] <- "Peru, 2011"

country_labels[25] <- "Zimbabwe, 2013"

## Output per capita rates before processing
for (cm in seq(1,length(proxy_contact_matrices))){
  file_name <- paste(country_labels[cm],' per capita.csv',sep='')
  # write.csv(proxy_contact_matrices[[cm]]$matrix.per.capita,file_name)
}


# COMPARISON: KL DIVERGENCE

# Measure two-way KL divergence between two input matrices (cm1,cm2)
kl_divergence_cm <- function(cm1,cm2){
  p_cm1 <- cm1$matrix.per.capita / sum(cm1$matrix.per.capita)
  p_cm2 <- cm2$matrix.per.capita / sum(cm2$matrix.per.capita)
  
  x <- rbind(as.vector(p_cm1),as.vector(p_cm2))
  y <- rbind(as.vector(p_cm2),as.vector(p_cm1))

  z <- c(KL(x, unit='log', epsilon=0.000000001),KL(y, unit='log', epsilon=0.000000001))
  
  return(mean(z))
}

KL_matrix <- matrix( 
  nrow=length(country_list),
  ncol=length(country_list))

colnames(KL_matrix) <- country_labels
rownames(KL_matrix) <- country_labels

for(i in 1:length(country_list)){
  for (j in 1:length(country_list)){
    KL_matrix[[i,j]] <- kl_divergence_cm(proxy_contact_matrices[[i]],proxy_contact_matrices[[j]])
  }   
}

# Clustering robustness check (see supplement) - measures variation in output of spectral clustering algorithm

# RobustnessChecker <- function(dist_matrix, cluster_no, nn, no_run){
# 
#   pair_matrix_total <- matrix(data=FALSE,nrow=nrow(KL_matrix), ncol=nrow(KL_matrix))
#   out <- c()
#   avg_pair <- c()
# 
#   for (sim in seq(1,no_run)){
#     sc <- specClust(dist_matrix,centers = cluster_no, nn=nn, method = "symmetric")
#     # out <- append(out,sc$cluster)
#     pair_matrix <- matrix(data=FALSE,nrow=nrow(KL_matrix), ncol=nrow(KL_matrix))
# 
#     for (i in seq(1,nrow(KL_matrix))){
#       for (j in seq(1,nrow(KL_matrix))){
#         if ((i!=j) && (sc$cluster[i]==sc$cluster[j])){
#           pair_matrix_total[i,j] <- TRUE
#           pair_matrix[i,j] <- TRUE
#         }
#       }
#     }
#     out <- append(out, sum(pair_matrix_total))
#     avg_pair <- append(avg_pair,sum(pair_matrix))
#     
#     
#   }
#   out <- append(out, mean(avg_pair))
#   return(out)
# }

# CompareClusters <- function(cluster_a, cluster_b){
#   
# }

# define space of input parameters to clustering algorithm to explore
# cluster_size <- seq(3,10)
# nearest_neighbors <- seq(4,8)

# define number of algorithm runs per parameter combination
# no_runs <- 1000

# robustness_matrix <- matrix(nrow=length(cluster_size), ncol=length(nearest_neighbors))
# 
# for (c in seq(1,length(cluster_size))){
#   for (n in seq(1,length(nearest_neighbors))){
#     r <- RobustnessChecker(KL_matrix,cluster_size[c],nearest_neighbors[n],no_runs)
#     robustness_matrix[c,n] <- r[(no_runs+1)] / r[no_runs]
#   }
# }


# OUTPUT RESULTS TO FILE

output_matrix <- matrix(nrow=33*33,ncol=3)

for (i in seq(1,length(proxy_contact_matrices))){
  for (j in seq(1,length(proxy_contact_matrices))){
    output_matrix[(((i-1)*length(proxy_contact_matrices)) + j),] <- c(country_labels[i],country_labels[j],
                                                                      KL_matrix[i,j])
  }
}

colnames(output_matrix) <- c('Country A', 'Country B', 'KL divergence - per capita')

# file_name <- 'output_similarity.csv'
# write.csv(output_matrix,file_name)

output_matrix_cluster <- matrix(nrow=length(country_labels),ncol=9)

output_matrix_cluster[,1] <- country_labels

sc_3 <- specClust(KL_matrix,centers = 3, nn=5, method = "symmetric")$cluster
output_matrix_cluster[,2] <- sc_3
sc_4 <- specClust(KL_matrix,centers = 4, nn=5, method = "symmetric")$cluster
output_matrix_cluster[,3] <- sc_4
sc_5 <- specClust(KL_matrix,centers = 5, nn=5, method = "symmetric")$cluster
output_matrix_cluster[,4] <- sc_5
sc_6 <- specClust(KL_matrix,centers = 6, nn=5, method = "symmetric")$cluster
output_matrix_cluster[,5] <- sc_6
sc_7 <- specClust(KL_matrix,centers = 7, nn=5, method = "symmetric")$cluster
output_matrix_cluster[,6] <- sc_7
sc_8 <- specClust(KL_matrix,centers = 8, nn=5, method = "symmetric")$cluster
output_matrix_cluster[,7] <- sc_8
sc_9 <- specClust(KL_matrix,centers = 9, nn=5, method = "symmetric")$cluster
output_matrix_cluster[,8] <- sc_9
sc_10 <- specClust(KL_matrix,centers = 10, nn=5, method = "symmetric")$cluster
output_matrix_cluster[,9] <- sc_10

colnames(output_matrix_cluster) <- c('Country', 'n_3', 'n_4', 'n_5', 'n_6', 'n_7', 'n_8', 'n_9', 'n_10')

# file_name <- 'output_cluster.csv'
# write.csv(output_matrix_cluster,file_name)


# COMPUTE AVERAGE CLUSTER MATRICES (See supplement)
# comix_cluster <- seq(1,17)
# polymod_cluster <- c(30, 27, 31, 28, 33, 32, 29, 26, 23, 18, 19, 22)
# 
# comix_avg <- proxy_contact_matrices[[1]]$matrix.per.capita / sum(proxy_contact_matrices[[1]]$matrix.per.capita)
# polymod_avg <- proxy_contact_matrices[[30]]$matrix.per.capita / sum(proxy_contact_matrices[[30]]$matrix.per.capita)
# 
# for (i in seq(2,length(comix_cluster))){
#   comix_avg <- comix_avg + ( proxy_contact_matrices[[comix_cluster[i]]]$matrix.per.capita / sum(proxy_contact_matrices[[comix_cluster[i]]]$matrix.per.capita) )
# }
# 
# for (i in seq(2,length(polymod_cluster))){
#   polymod_avg <- polymod_avg + ( proxy_contact_matrices[[polymod_cluster[i]]]$matrix.per.capita  / sum(proxy_contact_matrices[[polymod_cluster[i]]]$matrix.per.capita) )
# }
# 
# comix_avg <- comix_avg / length(comix_cluster)
# polymod_avg <- polymod_avg / length(polymod_cluster)
# 
# write.table(comix_avg, "comix_average_cluster_subset_v2.csv", sep = '\t')
# write.table(polymod_avg, "polymod_average_cluster_subset_v2.csv", sep = '\t')
