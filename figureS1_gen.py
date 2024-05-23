import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import csv

# Read in average matrices computed in R matrix analysis script
polymod_avg_in = {}

with open('Output/Average matrices/polymod_average.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        polymod_avg_in[row[0]] = [float(h) for h in row[1:]]

polymod_avg = pd.DataFrame(polymod_avg_in, index=list(polymod_avg_in.keys()))

comix_avg_in = {}

with open('Output/Average matrices/comix_average.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        comix_avg_in[row[0]] = [float(h) for h in row[1:]]

comix_avg = pd.DataFrame(comix_avg_in, index=list(comix_avg_in.keys()))

# Difference computed as subtraction of comix matrix from polymod matrix
diff = polymod_avg - comix_avg

# Plot each contact matrix and the differences as separate heatmaps in a grid
plt.rcParams.update({'font.size': 14})

fig, axs = plt.subplots(ncols=2, nrows=2, dpi=400, figsize=[15,11.25])
axs[-1, -1].axis('off')

row1_max = max([h for j in range(len(polymod_avg.values)) for h in polymod_avg.values[j]] + 
               [h for j in range(len(comix_avg.values)) for h in comix_avg.values[j]])

max_diff_overall = max([h for j in range(len(diff.values)) for h in diff.values[j]])

sns.heatmap(polymod_avg, cmap="YlGnBu", cbar_kws={'label': 'Contact rate per capita \n(rescaled)'}, vmax = row1_max, ax=axs[0][0]).invert_yaxis()
axs[0][0].set_xlabel('Age of Participant',weight="bold", fontsize='large')
axs[0][0].set_ylabel('Age of Contact',weight="bold", fontsize='large')
axs[0][0].set_title('Group 1 mean (POLYMOD group)',weight="bold", fontsize='large')

sns.heatmap(comix_avg, cmap="YlGnBu", cbar_kws={'label': 'Contact rate per capita \n(rescaled)'}, vmax = row1_max, ax=axs[0][1]).invert_yaxis()
axs[0][1].set_xlabel('Age of Participant',weight="bold", fontsize='large')
axs[0][1].set_ylabel('Age of Contact',weight="bold", fontsize='large')
axs[0][1].set_title('Group 2 mean (CoMix group)',weight="bold", fontsize='large')

sns.heatmap(diff, cmap="RdBu", cbar_kws={'label': '$\Delta$[POLYMOD - COMIX]'}, vmin = -1 * max_diff_overall,  vmax = max_diff_overall, ax=axs[1][0]).invert_yaxis()
axs[1][0].set_xlabel('Age of Participant',weight="bold", fontsize='large')
axs[1][0].set_ylabel('Age of Contact',weight="bold", fontsize='large')
axs[1][0].set_title('Difference',weight="bold", fontsize='large')

axs[0][0].text(-2,15.5,'a)', weight='bold', fontsize='large')
axs[0][1].text(-2,15.5,'b)', weight='bold', fontsize='large')
axs[1][0].text(-2,15.5,'c)', weight='bold', fontsize='large')



plt.tight_layout()
plt.savefig('Supp_fig_2.pdf')