import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import csv
import numpy as np
import matplotlib.ticker as tkr

# Read in household contact patterns derived from UK POLYMOD and CoMix surveys
polymod_household_in = {}

with open('Output/UK case study/polymod_household.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        polymod_household_in[row[0]] = [float(h) for h in row[1:]]

polymod_household = pd.DataFrame(polymod_household_in, index=list(polymod_household_in.keys()))

comix_household_in = {}

with open('Output/UK case study/comix_household.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        comix_household_in[row[0]] = [float(h) for h in row[1:]]

comix_household = pd.DataFrame(comix_household_in, index=list(comix_household_in.keys()))


# Read in age-specific fertility data from ONS dataset
birth_counts = {}

start_reading = False

with open('Data/birthsummary2022workbook.csv', newline='') as csvfile:
    reader = csv.reader(csvfile, delimiter=',', quotechar='"')
    for row in reader:
        if start_reading:
            birth_counts[int(row[0])] = []
            for i in row[2:8]:
                birth_counts[int(row[0])].append(int(i.replace(',', '')))
        if row[0] == "2021":
            start_reading = True
        if row[0] == "1980":
            start_reading = False

# Estimate number of parents in each age group from ONS data for POLYMOD and CoMix time periods
comix_read = 2020
polymod_read = 2005

comix_parents = []
for i in range(4):
    comix_parents.append([])
polymod_parents = []
for i in range(4):
    polymod_parents.append([])

age_groups = [[15,20],[20,25],[25,30],[30,35],[35,40],[40,45]]

# comix
for i in range(1980,comix_read+1):
    age = comix_read - i
    if 5 > age:
        for j in range(len(birth_counts[i])):
            num_parents = int(birth_counts[i][j] / 5)
            
            for k in range(age_groups[j][0],age_groups[j][1]):
                comix_parents[0] = comix_parents[0] + num_parents * [age + k]

    if 10 > age and 5 <= age:
        for j in range(len(birth_counts[i])):
            num_parents = int(birth_counts[i][j] / 5)
            
            for k in range(age_groups[j][0],age_groups[j][1]):
                comix_parents[1] = comix_parents[1] + num_parents * [age + k]

    if 15 > age and 10 <= age:
        for j in range(len(birth_counts[i])):
            num_parents = int(birth_counts[i][j] / 5)
            
            for k in range(age_groups[j][0],age_groups[j][1]):
                comix_parents[2] = comix_parents[2] + num_parents * [age + k]
    if 20 > age and 15 <= age:
        for j in range(len(birth_counts[i])):
            num_parents = int(birth_counts[i][j] / 5)
            
            for k in range(age_groups[j][0],age_groups[j][1]):
                comix_parents[3] = comix_parents[3] + num_parents * [age + k]

                
# polymod
for i in range(1980,polymod_read+1):
    age = polymod_read - i
    if 5 > age:
        for j in range(len(birth_counts[i])):
            num_parents = int(birth_counts[i][j] / 5)
            
            for k in range(age_groups[j][0],age_groups[j][1]):
                polymod_parents[0] = polymod_parents[0] + num_parents * [age + k] 

    if 10 > age and 5 <= age:
        for j in range(len(birth_counts[i])):
            num_parents = int(birth_counts[i][j] / 5)
            
            for k in range(age_groups[j][0],age_groups[j][1]):
                polymod_parents[1] = polymod_parents[1] + num_parents * [age + k] 

    if 15 > age and 10 <= age:
        for j in range(len(birth_counts[i])):
            num_parents = int(birth_counts[i][j] / 5)
            
            for k in range(age_groups[j][0],age_groups[j][1]):
                polymod_parents[2] = polymod_parents[2] + num_parents * [age + k]

    if 20 > age and 15 <= age:
        for j in range(len(birth_counts[i])):
            num_parents = int(birth_counts[i][j] / 5)
            
            for k in range(age_groups[j][0],age_groups[j][1]):
                polymod_parents[3] = polymod_parents[3] + num_parents * [age + k]

                
# Bin the parental age counts for each child 5 year age band
polymod_parents_binned = {
    '0-4': list(np.unique(np.digitize(polymod_parents[0],bins=range(15,47,5)),return_counts=True)[1]),
    '5-9': list(np.unique(np.digitize(polymod_parents[1],bins=range(20,52,5)),return_counts=True)[1]),
    '10-14': list(np.unique(np.digitize(polymod_parents[2],bins=range(25,57,5)),return_counts=True)[1]),
    '15-19': list(np.unique(np.digitize(polymod_parents[3],bins=range(30,62,5)),return_counts=True)[1])
}

comix_parents_binned = {
    '0-4': list(np.unique(np.digitize(comix_parents[0],bins=range(15,47,5)),return_counts=True)[1]),
    '5-9': list(np.unique(np.digitize(comix_parents[1],bins=range(20,52,5)),return_counts=True)[1]),
    '10-14': list(np.unique(np.digitize(comix_parents[2],bins=range(25,57,5)),return_counts=True)[1]),
    '15-19': list(np.unique(np.digitize(comix_parents[3],bins=range(30,62,5)),return_counts=True)[1])
}

# Normalise the parental age counts
polymod_parents_binned_norm = polymod_parents_binned
comix_parents_binned_norm = comix_parents_binned


for a in polymod_parents_binned:
    
    p_sum = sum(polymod_parents_binned[a])
    c_sum = sum(comix_parents_binned[a])
    
    for b in range(len(polymod_parents_binned[a])):
        polymod_parents_binned_norm[a][b] = polymod_parents_binned[a][b] / p_sum
        comix_parents_binned_norm[a][b] = comix_parents_binned[a][b] / c_sum

         
            
# Define the household contact rates computed from child-parent contact in UK POLYMOD and CoMix surveys
polymod_measured = {
    '0-4': [0.002853029,
            0.003907394,
            0.0083185210,
            0.009508341,
            0.007681956,
            0.0034425875,
            0.003631391],
    '5-9': [0.003046008,
            0.0063184205,
            0.011279664,
            0.011867244,
            0.0094526546,
            0.003347240,
            0.0023261347],
    '10-14': [0.0018543901,
              0.005910899,
              0.009442782,
              0.0113158916,
              0.005532764,
              0.0035213408,
              0.0031549948],
    '15-19': [0.002458984,
             0.005251187,
             0.0080383863,
             0.007411138,
             0.0043762855,
             0.0023379813,
             0.001878485]
}

comix_measured = {
    '0-4': [0.00178323623544144,
            0.00329945007672424, 
            0.00732018445628991,
            0.0130817852677296,
            0.016080643950954,
            0.00987625970233636, 
            0.00324323086004546], 
    '5-9': [0.00179623711847413,
             0.00296273570579302, 
             0.00661298526341455,
             0.0122797810117827, 
             0.0127803935586307, 
             0.00915019049629467,
             0.00434722798139341],
    '10-14': [0.00236954467215747,	
              0.00426220405014293,
              0.00866056887381744,
              0.0112465193765622,
              0.0120038395724526,
              0.00771998801632441,
              0.00376695452743777],
    '15-19': [0.0027516468378785,	
              0.00365054041558261,
              0.00669270976002071,
              0.00922291874443449,
              0.00802913816260479,
              0.00524608376320807,
              0.00292451056875256]
}

#Normalise to estimate proportion of parents in each age group
polymod_prop_measured = polymod_measured
comix_prop_measured = comix_measured


for a in polymod_measured:
    
    p_sum = sum(polymod_measured[a])
    c_sum = sum(comix_measured[a])
    
    for b in range(len(polymod_measured[a])):
        polymod_prop_measured[a][b] = polymod_measured[a][b] / p_sum
        comix_prop_measured[a][b] = comix_measured[a][b] / c_sum




# Plot contact patterns alongside distribution of parent ages computed from surveys and ONS data
plt.rcParams.update({'font.size': 14})

fig, axs = plt.subplots(ncols=2, nrows=2, dpi=400, figsize=[15,11.25])

row1_max = max([h for j in range(len(polymod_household.values)) for h in polymod_household.values[j]] + 
               [h for j in range(len(comix_household.values)) for h in comix_household.values[j]])

major_ticks = list(range(0,16,2))
minor_ticks = list(range(1,14,2))
tick_labels = [str(h) for h in range(0,75,10)]

formatter = tkr.ScalarFormatter(useMathText=True, useOffset=False)
formatter.set_scientific(True)
formatter.set_powerlimits((0, 0))

sns.heatmap(polymod_household, cmap="YlGnBu", cbar_kws={"format": formatter}, vmax = row1_max, ax=axs[0][0]).invert_yaxis()
axs[0][0].set_xlabel('Age of Participant (years)', weight='bold', fontsize='large')
axs[0][0].set_ylabel('HOUSEHOLD\nAge of Contact (years)',weight="bold", fontsize='large')
axs[0][0].set_title('POLYMOD',weight="bold", fontsize='large')
axs[0][0].set_yticks(ticks=major_ticks)
axs[0][0].set_yticks(ticks=minor_ticks, minor=True)
axs[0][0].set_yticklabels(tick_labels)
axs[0][0].set_xticks(ticks=major_ticks)
axs[0][0].set_xticks(ticks=minor_ticks, minor=True)
axs[0][0].set_xticklabels(tick_labels)
axs[0][0].tick_params(axis='both', which='major', labelsize=18)
cbar = axs[0][0].collections[0].colorbar
cbar.set_label(label='Contact rate (rescaled)', fontsize=18)
cbar.ax.tick_params(labelsize=18)
cbar.ax.yaxis.offsetText.set_fontsize(18)

sns.heatmap(comix_household, cmap="YlGnBu", cbar_kws={"format": formatter}, vmax = row1_max, ax=axs[0][1]).invert_yaxis()
axs[0][1].set_xlabel('Age of Participant (years)', weight='bold', fontsize='large')
axs[0][1].set_ylabel('Age of Contact (years)',weight="bold", fontsize='large')
axs[0][1].set_title('COMIX',weight="bold", fontsize='large')
axs[0][1].set_yticks(ticks=major_ticks)
axs[0][1].set_yticks(ticks=minor_ticks, minor=True)
axs[0][1].set_yticklabels(tick_labels)
axs[0][1].set_xticks(ticks=major_ticks)
axs[0][1].set_xticks(ticks=minor_ticks, minor=True)
axs[0][1].set_xticklabels(tick_labels)
axs[0][1].tick_params(axis='both', which='major', labelsize=18)
cbar = axs[0][1].collections[0].colorbar
cbar.set_label(label='Contact rate (rescaled)', fontsize=18)
cbar.ax.tick_params(labelsize=18)
cbar.ax.yaxis.offsetText.set_fontsize(18)


axs[0][0].axhline(6, xmin=(3.0/15), xmax=(4.0/15),linestyle='-', color='blue')
axs[0][0].axhline(13, xmin=(3.0/15), xmax=(4.0/15),linestyle='-', color='blue')
axs[0][0].axvline(3, ymin=(6.0/15), ymax=(13.0/15),linestyle='-', color='blue')
axs[0][0].axvline(4, ymin=(6.0/15), ymax=(13.0/15),linestyle='-', color='blue')


axs[0][1].axhline(6, xmin=(3.0/15), xmax=(4.0/15),linestyle='-', color='blue')
axs[0][1].axhline(13, xmin=(3.0/15), xmax=(4.0/15),linestyle='-', color='blue')
axs[0][1].axvline(3, ymin=(6.0/15), ymax=(13.0/15),linestyle='-', color='blue')
axs[0][1].axvline(4, ymin=(6.0/15), ymax=(13.0/15),linestyle='-', color='blue')


x = []
y = []
z = []

age_labels = {
    '0-4': ['[15,20)','[20,25)', '[25,30)', '[30,35)', '[35,40)', '[40,45)', '[45,50)'],
    '5-9': ['[20,25)', '[25,30)', '[30,35)', '[35,40)', '[40,45)', '[45,50)', '[50,55)'],
    '10-14': ['[25,30)', '[30,35)', '[35,40)', '[40,45)', '[45,50)', '[50,55)', '[55,60)'],
    '15-19': ['[30,35)', '[35,40)', '[40,45)', '[45,50)', '[50,55)', '[55,60)', '[60,65)']
}

for target_group in age_labels:
    x = x + age_labels[target_group] * 4
    
    y = y + polymod_parents_binned_norm[target_group]
    y = y + comix_parents_binned_norm[target_group]
    y = y + polymod_prop_measured[target_group]
    y = y + comix_prop_measured[target_group]
    
    z = z + [target_group] * 28
    
    

data_dic = {'Parent age': x, 
            'Child age': z,
            'Data Source': 4 * (['ONS'] * 14 + ['Contact Survey'] * 14), 
            'Survey year': 8 * (['2006 (POLYMOD)'] * 7 + ['2021 (CoMix)'] * 7),
            'Estimated proportion of parents': y,
           }

data = pd.DataFrame(data_dic)

data_ons_15_19 = data.loc[(data['Data Source'] == 'ONS') & (data['Child age'] == '15-19')]
data_survey_15_19 = data.loc[(data['Data Source'] == 'Contact Survey') & (data['Child age'] == '15-19')]

pal = sns.cubehelix_palette(2, rot=-.25, light=0.65, dark = 0.4)

sns.barplot(data=data_ons_15_19, x='Parent age', y='Estimated proportion of parents', hue='Survey year', ax=axs[1][1], palette=pal)
axs[1][1].set_title('CHILDREN AGED 15-19 (ONS)',weight="bold", fontsize='large')
axs[1][1].set_ylim(0,0.35)
axs[1][1].set_xlabel(axs[1][1].get_xlabel(), fontdict={'weight': 'bold'},fontsize='large')
axs[1][1].set_ylabel(axs[1][1].get_ylabel(), fontdict={'weight': 'bold'},fontsize='large')

sns.barplot(data=data_survey_15_19, x='Parent age', y='Estimated proportion of parents', hue='Survey year', ax=axs[1][0], palette=pal)
axs[1][0].set_title('CHILDREN AGED 15-19 (POLYMOD/COMIX)',weight="bold", fontsize='large')
axs[1][0].set_ylim(0,0.35)
axs[1][0].set_xlabel(axs[1][0].get_xlabel(), fontdict={'weight': 'bold'},fontsize='large')
axs[1][0].set_ylabel(axs[1][0].get_ylabel(), fontdict={'weight': 'bold'},fontsize='large')

axs[0][0].text(-2,15.5,'a)', weight='bold', fontsize='large')
axs[0][1].text(-2,15.5,'b)', weight='bold', fontsize='large')
axs[1][0].text(-1.25,0.365,'c)', weight='bold', fontsize='large')
axs[1][1].text(-1.25,0.365,'d)', weight='bold', fontsize='large')

plt.tight_layout()

plt.savefig('Figure 4.pdf')