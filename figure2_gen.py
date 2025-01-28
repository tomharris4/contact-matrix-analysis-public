import matplotlib.pyplot as plt
import matplotlib.ticker as tkr
import seaborn as sns
import pandas as pd
import csv

# Read in contact matrices for polymod/comix for overall, household, school and workplace settings

polymod_overall_in = {}

with open('Output/UK case study/polymod_overall.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        polymod_overall_in[row[0]] = [float(h) for h in row[1:]]

polymod_overall = pd.DataFrame(polymod_overall_in, index=list(polymod_overall_in.keys()))

polymod_household_in = {}

with open('Output/UK case study/polymod_household.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        polymod_household_in[row[0]] = [float(h) for h in row[1:]]

polymod_household = pd.DataFrame(polymod_household_in, index=list(polymod_household_in.keys()))

polymod_school_in = {}

with open('Output/UK case study/polymod_school.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        polymod_school_in[row[0]] = [float(h) for h in row[1:]]

polymod_school = pd.DataFrame(polymod_school_in, index=list(polymod_school_in.keys()))

polymod_work_in = {}

with open('Output/UK case study/polymod_work.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        polymod_work_in[row[0]] = [float(h) for h in row[1:]]

polymod_work = pd.DataFrame(polymod_work_in, index=list(polymod_work_in.keys()))

comix_overall_in = {}

with open('Output/UK case study/comix_overall.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        comix_overall_in[row[0]] = [float(h) for h in row[1:]]

comix_overall = pd.DataFrame(comix_overall_in, index=list(comix_overall_in.keys()))

comix_household_in = {}

with open('Output/UK case study/comix_household.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        comix_household_in[row[0]] = [float(h) for h in row[1:]]

comix_household = pd.DataFrame(comix_household_in, index=list(comix_household_in.keys()))

comix_school_in = {}

with open('Output/UK case study/comix_school.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        comix_school_in[row[0]] = [float(h) for h in row[1:]]

comix_school = pd.DataFrame(comix_school_in, index=list(comix_school_in.keys()))

comix_work_in = {}

with open('Output/UK case study/comix_work.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        comix_work_in[row[0]] = [float(h) for h in row[1:]]

comix_work = pd.DataFrame(comix_work_in, index=list(comix_work_in.keys()))


# Compute difference between CoMix and POLYMOD for each setting
diff_overall = polymod_overall - comix_overall
max_diff_overall = max([h for j in range(len(diff_overall.values)) for h in diff_overall.values[j]])

diff_household = polymod_household - comix_household
max_diff_household = max([h for j in range(len(diff_household.values)) for h in diff_household.values[j]])

diff_school = polymod_school - comix_school
max_diff_school = max([h for j in range(len(diff_school.values)) for h in diff_school.values[j]])

diff_work = polymod_work - comix_work
max_diff_work = max([h for j in range(len(diff_work.values)) for h in diff_work.values[j]])


# Plot each contact matrix and the differences as separate heatmaps in a grid
fig, axs = plt.subplots(ncols=3, nrows=4, dpi=400, figsize=[15,15])

row1_max = max([h for j in range(len(polymod_overall.values)) for h in polymod_overall.values[j]] + 
               [h for j in range(len(comix_overall.values)) for h in comix_overall.values[j]])

row2_max = max([h for j in range(len(polymod_household.values)) for h in polymod_household.values[j]] + 
               [h for j in range(len(comix_household.values)) for h in comix_household.values[j]])

row3_max = max([h for j in range(len(polymod_school.values)) for h in polymod_school.values[j]] + 
               [h for j in range(len(comix_school.values)) for h in comix_school.values[j]])

row4_max = max([h for j in range(len(polymod_work.values)) for h in polymod_work.values[j]] + 
               [h for j in range(len(comix_work.values)) for h in comix_work.values[j]])

major_ticks = list(range(0,16,2))
minor_ticks = list(range(1,14,2))
tick_labels = [str(h) for h in range(0,75,10)]

formatter = tkr.ScalarFormatter(useMathText=True, useOffset=False)
formatter.set_scientific(True)
formatter.set_powerlimits((0, 0))

print(formatter.get_offset())

sns.heatmap(polymod_overall, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row1_max, ax=axs[0][0]).invert_yaxis()
axs[0][0].set_ylabel('OVERALL\n\n',weight="bold", fontsize='xx-large')
axs[0][0].set_title('POLYMOD\n',weight="bold", fontsize='xx-large')
axs[0][0].set_yticks(ticks=major_ticks)
axs[0][0].set_yticks(ticks=minor_ticks, minor=True)
axs[0][0].set_yticklabels(tick_labels)
axs[0][0].set_xticks(ticks=major_ticks)
axs[0][0].set_xticks(ticks=minor_ticks, minor=True)
axs[0][0].tick_params(axis='both', which='major', labelsize=15)
cbar = axs[0][0].collections[0].colorbar
cbar.set_label(label='Contact rate (rescaled)', fontsize=15)
cbar.ax.tick_params(labelsize=15)
cbar.ax.yaxis.offsetText.set_fontsize(15)

sns.heatmap(polymod_household, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row2_max, ax=axs[1][0]).invert_yaxis()
axs[1][0].set_ylabel('HOUSEHOLD\n\n',weight="bold", fontsize='xx-large')
axs[1][0].set_yticks(ticks=major_ticks)
axs[1][0].set_yticks(ticks=minor_ticks, minor=True)
axs[1][0].set_yticklabels(tick_labels)
axs[1][0].set_xticks(ticks=major_ticks)
axs[1][0].set_xticks(ticks=minor_ticks, minor=True)
axs[1][0].tick_params(axis='both', which='major', labelsize=15)
cbar = axs[1][0].collections[0].colorbar
cbar.set_label(label='Contact rate (rescaled)', fontsize=15)
cbar.ax.tick_params(labelsize=15)
cbar.ax.yaxis.offsetText.set_fontsize(15)


sns.heatmap(polymod_school, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row3_max, ax=axs[2][0]).invert_yaxis()
axs[2][0].set_ylabel('SCHOOL\n\n',weight="bold", fontsize='xx-large')
axs[2][0].set_yticks(ticks=major_ticks)
axs[2][0].set_yticks(ticks=minor_ticks, minor=True)
axs[2][0].set_yticklabels(tick_labels)
axs[2][0].set_xticks(ticks=major_ticks)
axs[2][0].set_xticks(ticks=minor_ticks, minor=True)
axs[2][0].tick_params(axis='both', which='major', labelsize=15)
cbar = axs[2][0].collections[0].colorbar
cbar.set_label(label='Contact rate (rescaled)', fontsize=15)
cbar.ax.tick_params(labelsize=15)
cbar.ax.yaxis.offsetText.set_fontsize(15)


sns.heatmap(polymod_work, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row4_max, ax=axs[3][0]).invert_yaxis()
axs[3][0].set_ylabel('WORK\n\n',weight="bold", fontsize='xx-large')
axs[3][0].set_yticks(ticks=major_ticks)
axs[3][0].set_yticks(ticks=minor_ticks, minor=True)
axs[3][0].set_yticklabels(tick_labels)
axs[3][0].set_xticks(ticks=major_ticks)
axs[3][0].set_xticks(ticks=minor_ticks, minor=True)
axs[3][0].set_xticklabels(tick_labels)
axs[3][0].tick_params(axis='both', which='major', labelsize=15)
cbar = axs[3][0].collections[0].colorbar
cbar.set_label(label='Contact rate (rescaled)', fontsize=15)
cbar.ax.tick_params(labelsize=15)
cbar.ax.yaxis.offsetText.set_fontsize(15)

sns.heatmap(comix_overall, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row1_max, ax=axs[0][1]).invert_yaxis()
axs[0][1].set_title('COMIX\n',weight="bold", fontsize='xx-large')
axs[0][1].set_yticks(ticks=major_ticks)
axs[0][1].set_yticks(ticks=minor_ticks, minor=True)
axs[0][1].set_xticks(ticks=major_ticks)
axs[0][1].set_xticks(ticks=minor_ticks, minor=True)
axs[0][1].tick_params(axis='both', which='major', labelsize=15)
cbar = axs[0][1].collections[0].colorbar
cbar.set_label(label='Contact rate (rescaled)', fontsize=15)
cbar.ax.tick_params(labelsize=15)
cbar.ax.yaxis.offsetText.set_fontsize(15)

sns.heatmap(comix_household, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row2_max, ax=axs[1][1]).invert_yaxis()
axs[1][1].set_yticks(ticks=major_ticks)
axs[1][1].set_yticks(ticks=minor_ticks, minor=True)
axs[1][1].set_xticks(ticks=major_ticks)
axs[1][1].set_xticks(ticks=minor_ticks, minor=True)
axs[1][1].tick_params(axis='both', which='major', labelsize=15)
cbar = axs[1][1].collections[0].colorbar
cbar.set_label(label='Contact rate (rescaled)', fontsize=15)
cbar.ax.tick_params(labelsize=15)
cbar.ax.yaxis.offsetText.set_fontsize(15)

sns.heatmap(comix_school, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row3_max, ax=axs[2][1]).invert_yaxis()
axs[2][1].set_yticks(ticks=major_ticks)
axs[2][1].set_yticks(ticks=minor_ticks, minor=True)
axs[2][1].set_xticks(ticks=major_ticks)
axs[2][1].set_xticks(ticks=minor_ticks, minor=True)
axs[2][1].tick_params(axis='both', which='major', labelsize=15)
cbar = axs[2][1].collections[0].colorbar
cbar.set_label(label='Contact rate (rescaled)', fontsize=15)
cbar.ax.tick_params(labelsize=15)
cbar.ax.yaxis.offsetText.set_fontsize(15)

sns.heatmap(comix_work, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row4_max, ax=axs[3][1]).invert_yaxis()
axs[3][1].set_yticks(ticks=major_ticks)
axs[3][1].set_yticks(ticks=minor_ticks, minor=True)
axs[3][1].set_xticks(ticks=major_ticks)
axs[3][1].set_xticks(ticks=minor_ticks, minor=True)
axs[3][1].set_xticklabels(tick_labels)
axs[3][1].tick_params(axis='both', which='major', labelsize=15)
cbar = axs[3][1].collections[0].colorbar
cbar.set_label(label='Contact rate (rescaled)', fontsize=15)
cbar.ax.tick_params(labelsize=15)
cbar.ax.yaxis.offsetText.set_fontsize(15)



sns.heatmap(diff_overall, cmap="RdBu", cbar_kws={"format": formatter}, 
            center = 0, vmin = -1 * max_diff_overall,  vmax = max_diff_overall, ax=axs[0][2]).invert_yaxis()
axs[0][2].set_title('DIFFERENCE\n',weight="bold", fontsize='xx-large')
axs[0][2].set_yticks(ticks=major_ticks)
axs[0][2].set_yticks(ticks=minor_ticks, minor=True)
axs[0][2].set_xticks(ticks=major_ticks)
axs[0][2].set_xticks(ticks=minor_ticks, minor=True)
axs[0][2].tick_params(axis='both', which='major', labelsize=15)
cbar = axs[0][2].collections[0].colorbar
cbar.set_label(label='$\Delta$[POLYMOD - COMIX]', fontsize=15)
cbar.ax.tick_params(labelsize=15)
cbar.ax.yaxis.offsetText.set_fontsize(15)

sns.heatmap(diff_household, cmap="RdBu", cbar_kws={"format": formatter}, 
            center = 0, vmin = -1 * max_diff_household, vmax = max_diff_household, ax=axs[1][2]).invert_yaxis()
axs[1][2].set_yticks(ticks=major_ticks)
axs[1][2].set_yticks(ticks=minor_ticks, minor=True)
axs[1][2].set_xticks(ticks=major_ticks)
axs[1][2].set_xticks(ticks=minor_ticks, minor=True)
axs[1][2].tick_params(axis='both', which='major', labelsize=15)
cbar = axs[1][2].collections[0].colorbar
cbar.set_label(label='$\Delta$[POLYMOD - COMIX]', fontsize=15)
cbar.ax.tick_params(labelsize=15)
cbar.ax.yaxis.offsetText.set_fontsize(15)

sns.heatmap(diff_school, cmap="RdBu", cbar_kws={"format": formatter}, 
            center = 0, vmin = -1 * max_diff_school, vmax = max_diff_school, ax=axs[2][2]).invert_yaxis()
axs[2][2].set_yticks(ticks=major_ticks)
axs[2][2].set_yticks(ticks=minor_ticks, minor=True)
axs[2][2].set_xticks(ticks=major_ticks)
axs[2][2].set_xticks(ticks=minor_ticks, minor=True)
axs[2][2].tick_params(axis='both', which='major', labelsize=15)
cbar = axs[2][2].collections[0].colorbar
cbar.set_label(label='$\Delta$[POLYMOD - COMIX]', fontsize=15)
cbar.ax.tick_params(labelsize=15)
cbar.ax.yaxis.offsetText.set_fontsize(15)

sns.heatmap(diff_work, cmap="RdBu", cbar_kws={"format": formatter}, 
            center = 0, vmin = -1 * max_diff_work, vmax = max_diff_work, ax=axs[3][2]).invert_yaxis()
axs[3][2].set_yticks(ticks=major_ticks)
axs[3][2].set_yticks(ticks=minor_ticks, minor=True)
axs[3][2].set_xticks(ticks=major_ticks)
axs[3][2].set_xticks(ticks=minor_ticks, minor=True)
axs[3][2].set_xticklabels(tick_labels)
axs[3][2].tick_params(axis='both', which='major', labelsize=15)
cbar = axs[3][2].collections[0].colorbar
cbar.set_label(label='$\Delta$[POLYMOD - COMIX]', fontsize=15)
cbar.ax.tick_params(labelsize=15)
cbar.ax.yaxis.offsetText.set_fontsize(15)

axs[0][0].text(-3,15.5,'a)', weight='bold', fontsize='xx-large')
axs[1][0].text(-3,15.5,'d)', weight='bold', fontsize='xx-large')
axs[2][0].text(-3,15.5,'g)', weight='bold', fontsize='xx-large')
axs[3][0].text(-3,15.5,'j)', weight='bold', fontsize='xx-large')

axs[0][1].text(-2,15.5,'b)', weight='bold', fontsize='xx-large')
axs[1][1].text(-2,15.5,'e)', weight='bold', fontsize='xx-large')
axs[2][1].text(-2,15.5,'h)', weight='bold', fontsize='xx-large')
axs[3][1].text(-2,15.5,'k)', weight='bold', fontsize='xx-large')

axs[0][2].text(-2,15.5,'c)', weight='bold', fontsize='xx-large')
axs[1][2].text(-2,15.5,'f)', weight='bold', fontsize='xx-large')
axs[2][2].text(-2,15.5,'i)', weight='bold', fontsize='xx-large')
axs[3][2].text(-2,15.5,'l)', weight='bold', fontsize='xx-large')

axs[3][1].text(-2,-4.5,'Age of Participant (years)', weight='bold', fontsize='xx-large')
axs[1][0].text(-4.5,-10,'Age of Contact (years)', weight='bold', fontsize='xx-large',rotation=90)

plt.savefig('Figure 2.pdf')