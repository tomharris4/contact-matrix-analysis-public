# Untangling the contribution of survey design and demographic change to observed differences in age-stratified contact patterns

This data and code accompanies the journal article, 'Untangling the contribution of survey design and demographic change to observed differences in age-stratified contact patterns' by Harris et al.

## **File hierarchy**

-   README.md - readme file describing contents of repository

-   Data:

    -   Survey data used in analysis - '(C)' refers to survey from CoMix dataset, year provided when multiple surveys exist from same country. All survey data collected from socialcontactdata.org [1]

    -   Survey data includes: duplication of survey data provided from socialcontactdata.org [1] in base folder and 'Raw' secondary folder, pre-processed contact data in 'Processed' secondary folder, filtered data for the UK on stringency index in 'Filtered' secondary folder.

    -   Stringency index data (string) from Oxford Covid-19 Government Response Tracker (OxCGRT) [2]

    -   Office for National Statistics (ONS) age-specific fertility data [3]

-   Output:

    -   'output_similarity.csv': contact matrix comparison results from Kullback-Liebler (KL) divergence test (figure 1)

    -   'output_cluster.csv': clustering results for KL comparison over set of surveys (figure 1)

    -   Re-scaled per capita contact matrices: per capita contact matrices for each survey compared in analysis

    -   Average matrices: average matrices computed over clusters of contact matrices

    -   UK case study: UK POLYMOD and CoMix contact matrices filtered on location. CoMix contact matrices also filtered on intervention stringency and contact type (i.e., group vs. individuals) 

    -   Robustness tables: robustness of clustering process for different number of clusters and nearest neighbor settings

    -   Age densities: parent/child age probability densities (generated from 'Age specific fetility.ipynb')

    -   Reclustering: clustering results under different assumptions relating to filtering of contacts and re-processing of contact/participant ages


-   'contact-matrix-analysis.R': main analysis script

    -   Reads in processed survey data from Data folder
    -   Constructs contact matrices using socialmixr methods
    -   Compares contact matrices using defined measures of similarity - KL divergence

-   'contact-matrix-analysis-filtering-SIR.R': additional analysis script

    -   Same as 'contact-matrix-analysis.R' with additional features for filtering matrices and inputting matrices into age-structured SIR model

-   'process-surveys.R': script for pre-processing survey data

    -   Reads in raw survey data from Data folder
    -   Establishes country and year of survey
    -   Constructs kernel density of age distribution for population
    -   Estimates specific age for age brackets in survey data
    -   Saves processed survey data in Data folder

-   'UK analysis.R': script for generating contact matrices derived from UK CoMix and POLYMOD survey, filtered on location for both surveys and stringency index & contact type (group/individual) for just CoMix survey

-   'process_other_surveys.ipynb': ipython notebook for splitting China (2020) & Zimbabwe contact surveys on survey site and time of survey

-   'process-surveys_UK_POLYMOD.R': script for re-assigning ages in UK POLYMOD survey under different assumptions

-   'Age specific fertility.ipynb': ipython notebook for generating parent/child age densities

-   'filter-on-stringency-index.ipynb': script for filtering UK CoMix survey on stringency index associated with each survey day

-   '*_gen.py/ipynb' files: scripts for generating figures appearing in manuscript


## Output

The data outputted from our analysis include:

-   Contact matrices:

    -   csv files listing contact strength between age groups defined in header of rows and columns. Output folder includes contact matrices for each survey and averages over POLYMOD/CoMix groups

-   Similarity:

    -   csv file listing similarity between contact matrices derived from survey set

-   Clustering:

    -   csv file listing cluster groups for each survey. Columns refer to various #cluster settings.



## Requirements

-   python3(3.9.7)

    -   notebook (6.4.5), numpy (1.20.3), pandas (1.3.4), os , re, csv, datetime, seaborn (0.11.2)

-   R (4.1.3)

    -   socialmixr (0.2.0), deSolve (1.32), kknn (1.3.1), philentropy (0.7.0)

## Setup

NOTE: if accessing repo through github, to adhere to maximum file size requirements on github, the CoMix United Kingdom data has been compressed. Please unzip and replace the csv files at 'Data/United Kingdom (C)/Processed/CoMix_uk_contact_common.csv.zip' & 'Data/United Kingdom (C)/Raw/CoMix_uk_contact_common.csv.zip', before running any analysis scripts.

1.  Run 'contact-matrix-analysis.R' to generate & compare matrices, and output data from main analysis.

## References

1. Willem, Lander, et al. "SOCRATES: an online tool leveraging a social contact data sharing initiative to assess mitigation strategies for COVID-19." BMC research notes 13.1 (2020): 293.

2. Edouard Mathieu, Hannah Ritchie, Lucas Rodés-Guirao, Cameron Appel, Charlie Giattino, Joe Hasell, Bobbie Macdonald, Saloni Dattani, Diana Beltekian, Esteban Ortiz-Ospina and Max Roser (2020) - "Coronavirus Pandemic (COVID-19)". Published online at OurWorldInData.org. Retrieved from: 'https://ourworldindata.org/coronavirus' [Online Resource]

3. Office for National Statistics (ONS) - Births in England and Wales: summary tables, 2022. Contains public sector information licensed under the Open Government Licence v3.0.; 2022. Available from: www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/datasets/birthsummarytables.
