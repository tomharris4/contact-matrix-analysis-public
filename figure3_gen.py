import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import csv
import matplotlib.ticker as tkr

# Read in contact matrices for individual/group contacts in schools and workplaces
comix_ind_school_in = {}

with open('Output/UK case study/comix_ind_school.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        comix_ind_school_in[row[0]] = [float(h) for h in row[1:]]

comix_ind_school = pd.DataFrame(comix_ind_school_in, index=list(comix_ind_school_in.keys()))

comix_group_school_in = {}

with open('Output/UK case study/comix_group_school.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        comix_group_school_in[row[0]] = [float(h) for h in row[1:]]

comix_group_school = pd.DataFrame(comix_group_school_in, index=list(comix_group_school_in.keys()))

comix_ind_work_in = {}

with open('Output/UK case study/comix_ind_work.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        comix_ind_work_in[row[0]] = [float(h) for h in row[1:]]

comix_ind_work = pd.DataFrame(comix_ind_work_in, index=list(comix_ind_work_in.keys()))

comix_group_work_in = {}

with open('Output/UK case study/comix_group_work.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        comix_group_work_in[row[0]] = [float(h) for h in row[1:]]

comix_group_work = pd.DataFrame(comix_group_work_in, index=list(comix_group_work_in.keys()))

plt.rcParams.update({'font.size': 14})

# Plot each contact matrix as separate heatmap in grid
fig, axs = plt.subplots(ncols=2, nrows=2, dpi=400, figsize=[15,11.25])

row1_max = max([h for j in range(len(comix_ind_school.values)) for h in comix_ind_school.values[j]] + 
               [h for j in range(len(comix_group_school.values)) for h in comix_group_school.values[j]])

row2_max = max([h for j in range(len(comix_ind_work.values)) for h in comix_ind_work.values[j]] + 
               [h for j in range(len(comix_group_work.values)) for h in comix_group_work.values[j]])

major_ticks = list(range(0,16,2))
minor_ticks = list(range(1,14,2))
tick_labels = [str(h) for h in range(0,75,10)]

formatter = tkr.ScalarFormatter(useMathText=True, useOffset=False)
formatter.set_scientific(True)
formatter.set_powerlimits((0, 0))

sns.heatmap(comix_ind_school, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row1_max, ax=axs[0][0]).invert_yaxis()
axs[0][0].set_ylabel('SCHOOL\n\n',weight="bold", fontsize='large')
axs[0][0].set_title('COMIX (INDIVIDUAL CONTACTS)',weight="bold", fontsize='large')
axs[0][0].set_yticks(ticks=major_ticks)
axs[0][0].set_yticks(ticks=minor_ticks, minor=True)
axs[0][0].set_yticklabels(tick_labels)
axs[0][0].set_xticks(ticks=major_ticks)
axs[0][0].set_xticks(ticks=minor_ticks, minor=True)
axs[0][0].tick_params(axis='both', which='major', labelsize=18)
cbar = axs[0][0].collections[0].colorbar
cbar.set_label(label='Contact rate (rescaled)', fontsize=18)
cbar.ax.tick_params(labelsize=18)
cbar.ax.yaxis.offsetText.set_fontsize(18)

sns.heatmap(comix_ind_work, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row2_max, ax=axs[1][0]).invert_yaxis()
axs[1][0].set_ylabel('WORK\n\n',weight="bold", fontsize='large')
axs[1][0].set_yticks(ticks=major_ticks)
axs[1][0].set_yticks(ticks=minor_ticks, minor=True)
axs[1][0].set_yticklabels(tick_labels)
axs[1][0].set_xticks(ticks=major_ticks)
axs[1][0].set_xticks(ticks=minor_ticks, minor=True)
axs[1][0].set_xticklabels(tick_labels)
axs[1][0].tick_params(axis='both', which='major', labelsize=18)
cbar = axs[1][0].collections[0].colorbar
cbar.set_label(label='Contact rate (rescaled)', fontsize=18)
cbar.ax.tick_params(labelsize=18)
cbar.ax.yaxis.offsetText.set_fontsize(18)

sns.heatmap(comix_group_school, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row1_max, ax=axs[0][1]).invert_yaxis()
axs[0][1].set_title('COMIX (GROUP CONTACTS)',weight="bold", fontsize='large')
axs[0][1].set_yticks(ticks=major_ticks)
axs[0][1].set_yticks(ticks=minor_ticks, minor=True)
axs[0][1].set_xticks(ticks=major_ticks)
axs[0][1].set_xticks(ticks=minor_ticks, minor=True)
axs[0][1].tick_params(axis='both', which='major', labelsize=18)
cbar = axs[0][1].collections[0].colorbar
cbar.set_label(label='Contact rate (rescaled)', fontsize=18)
cbar.ax.tick_params(labelsize=18)
cbar.ax.yaxis.offsetText.set_fontsize(18)

sns.heatmap(comix_group_work, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row2_max, ax=axs[1][1]).invert_yaxis()
axs[1][1].set_yticks(ticks=major_ticks)
axs[1][1].set_yticks(ticks=minor_ticks, minor=True)
axs[1][1].set_xticks(ticks=major_ticks)
axs[1][1].set_xticks(ticks=minor_ticks, minor=True)
axs[1][1].set_xticklabels(tick_labels)
axs[1][1].tick_params(axis='both', which='major', labelsize=18)
cbar = axs[1][1].collections[0].colorbar
cbar.set_label(label='Contact rate (rescaled)', fontsize=18)
cbar.ax.tick_params(labelsize=18)
cbar.ax.yaxis.offsetText.set_fontsize(18)

axs[0][0].axhline(1, linestyle='--', color='blue')
axs[0][0].axhline(2, linestyle='--', color='blue')
axs[0][0].axhline(3, linestyle='--', color='blue')
axs[0][0].axhline(4, linestyle='--', color='blue')
axs[0][0].axhline(5, linestyle='--', color='blue')
axs[0][0].axhline(7, linestyle='--', color='blue')
axs[0][0].axhline(9, linestyle='--', color='blue')
axs[0][0].axhline(11, linestyle='--', color='blue')
axs[0][0].axhline(13, linestyle='--', color='blue')
axs[0][0].axhline(14, linestyle='--', color='blue')
axs[0][0].axvline(1, linestyle='--', color='blue')
axs[0][0].axvline(2, linestyle='--', color='blue')
axs[0][0].axvline(3, linestyle='--', color='blue')
axs[0][0].axvline(4, linestyle='--', color='blue')
axs[0][0].axvline(5, linestyle='--', color='blue')
axs[0][0].axvline(7, linestyle='--', color='blue')
axs[0][0].axvline(9, linestyle='--', color='blue')
axs[0][0].axvline(11, linestyle='--', color='blue')
axs[0][0].axvline(13, linestyle='--', color='blue')
axs[0][0].axvline(14, linestyle='--', color='blue')

axs[1][0].axhline(1, linestyle='--', color='blue')
axs[1][0].axhline(2, linestyle='--', color='blue')
axs[1][0].axhline(3, linestyle='--', color='blue')
axs[1][0].axhline(4, linestyle='--', color='blue')
axs[1][0].axhline(5, linestyle='--', color='blue')
axs[1][0].axhline(7, linestyle='--', color='blue')
axs[1][0].axhline(9, linestyle='--', color='blue')
axs[1][0].axhline(11, linestyle='--', color='blue')
axs[1][0].axhline(13, linestyle='--', color='blue')
axs[1][0].axhline(14, linestyle='--', color='blue')
axs[1][0].axvline(1, linestyle='--', color='blue')
axs[1][0].axvline(2, linestyle='--', color='blue')
axs[1][0].axvline(3, linestyle='--', color='blue')
axs[1][0].axvline(4, linestyle='--', color='blue')
axs[1][0].axvline(5, linestyle='--', color='blue')
axs[1][0].axvline(7, linestyle='--', color='blue')
axs[1][0].axvline(9, linestyle='--', color='blue')
axs[1][0].axvline(11, linestyle='--', color='blue')
axs[1][0].axvline(13, linestyle='--', color='blue')
axs[1][0].axvline(14, linestyle='--', color='blue')

axs[0][1].axhline(4, linestyle='--', color='blue')
axs[0][1].axhline(13, linestyle='--', color='blue')
axs[0][1].axvline(4, linestyle='--', color='blue')
axs[0][1].axvline(13, linestyle='--', color='blue')

axs[1][1].axhline(4, linestyle='--', color='blue')
axs[1][1].axhline(13, linestyle='--', color='blue')
axs[1][1].axvline(4, linestyle='--', color='blue')
axs[1][1].axvline(13, linestyle='--', color='blue')

axs[0][0].text(-2,15.5,'a)', weight='bold', fontsize='large')
axs[0][1].text(-2,15.5,'b)', weight='bold', fontsize='large')
axs[1][0].text(-2,15.5,'c)', weight='bold', fontsize='large')
axs[1][1].text(-2,15.5,'d)', weight='bold', fontsize='large')

axs[1][1].text(-11,-3.25,'Age of Participant (years)', weight='bold', fontsize='x-large')
axs[0][0].text(-3.25,-8.5,'Age of Contact (years)', weight='bold', fontsize='x-large',rotation=90)


plt.savefig('Figure 5 (seaborn)_censored.pdf')