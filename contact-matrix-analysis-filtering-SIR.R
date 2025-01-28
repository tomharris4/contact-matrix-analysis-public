library(socialmixr)
library(deSolve)
library(kknn)
library(philentropy)
library(reshape2)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load in all non-national age demographics 
load('Data/China, 2020/Shanghai_demographics.Rda')
load('Data/China, 2020/Wuhan_demographics.Rda')
load('Data/Peru/Peru_demographics.Rda')
load('Data/Zimbabwe/Peri_urban_demographics.Rda')
load('Data/Zimbabwe/Farm_demographics.Rda')

demos <- list(shanghai_demo,wuhan_demo, peru_demo, peri_urban_demo, farm_demo)

# Lower age bounds for age groupings
age_grouping <- seq(0,70,5)

# Boolean flag for whether to apply demographic projection to UK POLYMOD matrix
demo_projection <- FALSE

# Target CoMix survey country for filtering
comix_target_country <- 'United Kingdom'

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
  if (surveys[[country]][1] == 'United Kingdom' && surveys[[country]][3] > 2018) {
    cs$participants$year <- cs$participants$year + 2000
  }
  
  # append to surveys vector
  non_polymod_contact_surveys[[country]] <- cs
}


# DEFINE NORMAL & PER CAPITA CONTACT MATRICES - APPLY SYMMETRY CORRECTION & AGE SPECIFIC PARTICIPANT WEIGHTING

proxy_contact_matrices <- list()

set.seed(20180217)

# POLYMOD COUNTRIES

polymod_countries <- survey_countries(polymod)

for(i in 1:length(polymod_countries)){
  if (demo_projection && polymod_countries[i] == 'United Kingdom'){
    file_list <- list.files('Data/POLYMOD/Processed/Blurred',full.names = TRUE)
    polymod_processed <- load_survey(file_list)

    cm <- contact_matrix(survey=polymod_processed,
                         countries='United Kingdom',
                         age.limits=age_grouping,
                         # filter = list(cnt_home = 1), # context filter
                         symmetric = TRUE,
                         weigh.age = TRUE,
                         per.capita = FALSE)
    
    # Manual assignment of pre-processed UK POLYMOD survey for blurring and demographic projection experiments
    cm$matrix.per.capita <- as.numeric(unlist(read.csv('Output/UK case study/polymod_full_cd.csv', header=TRUE, sep = '\t')))
    
    
  }else {
    cm <- contact_matrix(survey=polymod,
                         countries=polymod_countries[i],
                         age.limits=age_grouping,
                         # filter = list(cnt_home = 1), # context filter
                         symmetric = TRUE,
                         weigh.age = TRUE,
                         per.capita = TRUE)
  
  }
  proxy_contact_matrices[[length(country_list) + i]] <- cm
}

# NON-POLYMOD COUNTRIES

for(i in 1:length(non_polymod_contact_surveys)){
  print(country_list[i])
  if (is.na(surveys[[i]][4])){
    # if comix, apply 50 contact limit
    if (grepl("(C)",country_labels[i], ignore.case = FALSE, fixed =TRUE)){
      # Check if CoMix target country
      if (country_list[i] == comix_target_country){
        cm <- contact_matrix(survey=non_polymod_contact_surveys[[i]],
                             countries=country_list[i],
                             age.limits=age_grouping,
                             filter = list(cnt_large_inc = 1), #, cnt_home = 1), # context filter
                             symmetric = TRUE, 
                             weigh.age = TRUE,
                             per.capita = TRUE)

      } else{
        cm <- contact_matrix(survey=non_polymod_contact_surveys[[i]],
                           countries=country_list[i],
                           age.limits=age_grouping,
                           filter = list(cnt_large_inc = 1), #, cnt_home = 1), # context filter
                           symmetric = TRUE, 
                           weigh.age = TRUE,
                           per.capita = TRUE)
      }
    } else{
      print(country_list[i])
      cm <- contact_matrix(survey=non_polymod_contact_surveys[[i]],
                           countries=country_list[i],
                           age.limits=age_grouping,
                           # filter = list(cnt_home = 1), # context filter
                           symmetric = TRUE, 
                           weigh.age = TRUE,
                           per.capita = TRUE)
    }
  } else{
    cm <- contact_matrix(survey=non_polymod_contact_surveys[[i]],
                         survey.pop=demos[[as.integer(surveys[[i]][4])]],
                         age.limits=age_grouping,
                         # filter = list(cnt_home = 1), # context filter
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
  # proxy_contact_matrices[[cm]]$matrix.per.capita <- apply_row_col_labels(proxy_contact_matrices[[cm]]$matrix.per.capita,age_labels,age_labels)
}

country_labels[20] <- "China (Shanghai), 2018"
country_labels[21] <- "France, 2012"
country_labels[22] <- "Hong Kong, 2016"
country_labels[23] <- "Peru, 2011"
country_labels[24] <- "Zimbabwe, 2013"

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

output_matrix <- matrix(nrow=32*32,ncol=3)

for (i in seq(1,length(proxy_contact_matrices))){
  for (j in seq(1,length(proxy_contact_matrices))){
    output_matrix[(((i-1)*length(proxy_contact_matrices)) + j),] <- c(country_labels[i],country_labels[j],
                                                                      KL_matrix[i,j])
  }
}

colnames(output_matrix) <- c('Country A', 'Country B', 'KL divergence - per capita')

file_name <- 'output_similarity_home_c_adjusted.csv'
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

file_name <- 'output_cluster_home_c_adjusted.csv'
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




# SIR MODEL COMPARISON (See supplement)

comix_ind <- 17
polymod_ind <- 30


# COMIX
matrix_1 <- proxy_contact_matrices[[comix_ind]]$matrix.per.capita / sum(proxy_contact_matrices[[comix_ind]]$matrix.per.capita)

# POLYMOD
matrix_2 <- proxy_contact_matrices[[polymod_ind]]$matrix.per.capita / sum(proxy_contact_matrices[[polymod_ind]]$matrix.per.capita)
# matrix_2 <- read.csv('Output/UK case study/polymod_comix_c.csv', header=TRUE, sep = '\t')
# matrix_2 <- read.csv('Output/UK case study/polymod_original.csv', header=TRUE, sep = '\t')

# Target demography
target_demo_pop <- proxy_contact_matrices[[comix_ind]]$demography$population
target_demo_prop <- proxy_contact_matrices[[comix_ind]]$demography$proportion
total_pop <- sum(proxy_contact_matrices[[comix_ind]]$demography$population)


# SARS-CoV-2
gamma <- 0.2

relative_susceptibility <- c(0.45, 0.45, 0.43, 0.43, 0.90, 0.90, 0.98, 0.98, 0.91, 0.91, 0.93, 0.93, 1, 1, 0.84)

target_R0 <- 2.9

base_beta = matrix(0.82425,
                   nrow=2,
                   ncol=1)

beta_scalers <- matrix(nrow=2, ncol=1)


# Compute base_beta as N*N matrix of base_betas relevant to each contact matrix, so that all R0s derived from
# NGMs are the same.
R_from_NGM <- function(cm, p_ratio, base_beta){

  betas = base_beta * relative_susceptibility

  T <- matrix(nrow=nrow(cm),ncol=nrow(cm))

  for(i in seq(1,nrow(cm))){
    for(j in seq(1,nrow(cm))){
      T[i,j] <- betas[i] * p_ratio[i,j] * as.numeric(cm[i,j])
    }

  }

  sigma <- -1 * diag(rep(gamma,nrow(cm)))

  E <- matrix(data=diag(rep(1,nrow(cm))),nrow=nrow(cm),ncol=nrow(cm))

  K <- - t(E) %*% T %*% solve(sigma) %*% E

  y <- eigen(K)

  R_fin <- y$val[1]

  return(as.numeric(R_fin))


}

p_split = target_demo_pop

p = matrix(nrow=length(p_split),ncol=length(p_split))

for(k in seq(1,length(p_split))){
  for(l in seq(1,length(p_split))){
    p[k,l] <- p_split[k]
  }

}

R_poly <- R_from_NGM(matrix_2, p, base_beta = base_beta[[1,1]])

p_split = target_demo_pop

p = matrix(nrow=length(p_split),ncol=length(p_split))

for(k in seq(1,length(p_split))){
  for(l in seq(1,length(p_split))){
    p[k,l] <- p_split[k]
  }

}

R_comix<- R_from_NGM(matrix_1, p, base_beta[[2,1]])

beta_scalers[[1,1]] <- R_poly / target_R0
beta_scalers[[2,1]] <- R_comix / target_R0

base_beta[[1,1]] <- base_beta[[1,1]] / beta_scalers[[1,1]]
base_beta[[2,1]] <- base_beta[[2,1]] / beta_scalers[[2,1]]



A = length(relative_susceptibility)

# Age-structured SIR model of disease spread
sir_model <- function(time,state,parameters){
  with(as.list(c(state,parameters)),{

    S <- state[1:A]
    I <- state[(A+1):(2*A)]
    R <- state[(2*A+1):(3*A)]

    gamma <- parameters[[1]]
    betas <- parameters[[2]]
    c <- parameters[[3]]
    N_split <- parameters[[4]]

    lambda = matrix(nrow=A,ncol=A)

    for(i in seq(1,A)){
      for(j in seq(1,A)){
        lambda[i,j] <- betas[i] * I[j] * c[i,j]
      }
    }

    dS <- c()
    dI <- c()
    dR <- c()

    for(i in seq(1,A)){
      dS[i] <- -1 * sum(lambda[i,]) * S[i]
      dI[i] <- sum(lambda[i,]) * S[i] - gamma*I[i]
      dR[i] <- gamma*I[i]
    }

    return(list(c(dS,dI,dR)))
  }
  )
}

par(mfrow=c(5,3), mar=c(3,3,1.75,0.25))
age_brackets <- c('0 - 4 years old',
                  '5 - 9 years old',
                  '10 - 14 years old',
                  '15 - 19 years old',
                  '20 - 24 years old',
                  '25 - 29 years old',
                  '30 - 34 years old',
                  '35 - 39 years old',
                  '40 - 44 years old',
                  '45 - 49 years old',
                  '50 - 54 years old',
                  '55 - 59 years old',
                  '60 - 64 years old',
                  '65 - 69 years old',
                  '70+ years old')

output_sir <- matrix(nrow = 15, ncol = 3)

for (h in 2:16){
  for (k in 1:2){

    # 1 = POLYMOD, 2 CoMix
    temp = k

    beta = base_beta[[temp,1]]
    proportion = target_demo_prop

    betas = beta * relative_susceptibility

    # Model inputs

    N = total_pop

    I_init = 50

    N_split = proportion * N

    age_target <- h
    split_age_target = age_target - 1

    N_target <- sum(N_split[split_age_target])

    # Time points
    time=seq(from=1,to=200,by=1)

    if (temp==1){
      parameters=list(gamma,
                      betas,
                      matrix_2,
                      N_split)
    } else {
      parameters=list(gamma,
                      betas,
                      matrix_1,
                      N_split)
    }


    S <- c()
    I <- c()
    R <- c()

    for(i in seq(1,A)){
      S[i] <- N_split[i] - I_init
      I[i] <- I_init
      R[i] <- 0
    }

    initial_state_values <- c(S,I,R)

    output<-as.data.frame(ode(y=initial_state_values,func = sir_model,parms=parameters,times = time))

    if (temp==1){
      out_poly <- output
    } else {
      out_comix <- output
    }


    age_grp_labels = c('S[0,5)','S[5,10)','S[10,15)','S[15,20)','S[20,25)','S[25,30)','S[30,35)','S[35,40)','S[40,45)','S[45,50)','S[50,55)','S[55,60)','S[60,65)','S[65,70)','S[70+)',
                       'I[0,5)','I[5,10)','I[10,15)','I[15,20)','I[20,25)','I[25,30)','I[30,35)','I[35,40)','I[40,45)','I[45,50)','I[50,55)','I[55,60)','I[60,65)','I[65,70)','I[70+)',
                       'R[0,5)','R[5,10)','R[10,15)','R[15,20)','R[20,25)','R[25,30)','R[30,35)','R[35,40)','R[40,45)','R[45,50)','R[50,55)','R[55,60)','R[60,65)','R[65,70)','R[70+)'
    )


    out_long=melt(output,id="time")

    if (temp == 1){
      y = rowSums(output[age_target:age_target])

      inc_polymod <- c()
      cum_cases_polymod <- c()
      cum_cases <- 0

      for(i in seq(2,length(y))){
        inc_polymod <- append(inc_polymod,y[i-1]-y[i])
        cum_cases <- cum_cases + y[i-1] - y[i]
        cum_cases_polymod <- append(cum_cases_polymod,cum_cases)
      }
    } else {
      y = rowSums(output[age_target:age_target])

      inc_comix <- c()
      cum_cases_comix <- c()
      cum_cases <- 0

      for(i in seq(2,length(y))){
        inc_comix <- append(inc_comix,y[i-1]-y[i])
        cum_cases <- cum_cases + y[i-1] - y[i]
        cum_cases_comix <- append(cum_cases_comix,cum_cases)
      }
    }
  }

  days <- seq(1,199)

  output_sir[h-1,1] <- cum_cases_polymod[199]/N_target
  output_sir[h-1,2] <- cum_cases_comix[199]/N_target
  output_sir[h-1,3] <- abs(cum_cases_polymod[199]/N_target - cum_cases_comix[199]/N_target)

  print(cum_cases_polymod[199])
  print(cum_cases_comix[199])

  plot(days,cum_cases_comix/N_target,type='l',ylab='Cumulative infected', col='#1f77b4', xlab='Days', xlim=c(0,200), ylim = c(0,1))
  lines(days,cum_cases_polymod/N_target,col='#ff7f0e')
  if (h==2){
    legend(100,0.55,c('CoMix','POLYMOD'),col=c('#1f77b4','#ff7f0e'),pch=16, bty = "n")
  }
  title(main=age_brackets[h-1])

}

print(invisible(sapply(round(output_sir,3), cat, "\n")))





