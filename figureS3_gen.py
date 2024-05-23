import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import csv
import matplotlib.ticker as tkr

# Read in overall contact matrices split on intervention stringency 
comix_overall_weakest_in = {}

with open('Output/UK case study/comix_overall_weakest.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        comix_overall_weakest_in[row[0]] = [float(h) for h in row[1:]]

comix_overall_weakest = pd.DataFrame(comix_overall_weakest_in, index=list(comix_overall_weakest_in.keys()))

comix_overall_weak_in = {}

with open('Output/UK case study/comix_overall_weak.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        comix_overall_weak_in[row[0]] = [float(h) for h in row[1:]]

comix_overall_weak = pd.DataFrame(comix_overall_weak_in, index=list(comix_overall_weak_in.keys()))

comix_overall_strong_in = {}

with open('Output/UK case study/comix_overall_strong.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        comix_overall_strong_in[row[0]] = [float(h) for h in row[1:]]

comix_overall_strong = pd.DataFrame(comix_overall_strong_in, index=list(comix_overall_strong_in.keys()))


comix_overall_strongest_in = {}

with open('Output/UK case study/comix_overall_strongest.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        comix_overall_strongest_in[row[0]] = [float(h) for h in row[1:]]

comix_overall_strongest = pd.DataFrame(comix_overall_strongest_in, index=list(comix_overall_strongest_in.keys()))


# Plot each contact matrix as separate heatmaps in a grid
plt.rcParams.update({'font.size': 14})

fig, axs = plt.subplots(ncols=2, nrows=2, dpi=400, figsize=[15,11.25])

matrix_max = max([h for j in range(len(comix_overall_weakest.values)) for h in comix_overall_weakest.values[j]] + 
               [h for j in range(len(comix_overall_weak.values)) for h in comix_overall_weak.values[j]] +
               [h for j in range(len(comix_overall_strong.values)) for h in comix_overall_strong.values[j]] + 
               [h for j in range(len(comix_overall_strongest.values)) for h in comix_overall_strongest.values[j]])

major_ticks = list(range(0,16,2))
minor_ticks = list(range(1,14,2))
tick_labels = [str(h) for h in range(0,75,10)]

formatter = tkr.ScalarFormatter(useMathText=True, useOffset=False)
formatter.set_scientific(True)
formatter.set_powerlimits((0, 0))

sns.heatmap(comix_overall_weakest, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = matrix_max, ax=axs[0][0]).invert_yaxis()
axs[0][0].set_title('STRINGENCY:\n less than 40',weight="bold", fontsize='large')
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

sns.heatmap(comix_overall_strong, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = matrix_max, ax=axs[1][0]).invert_yaxis()
axs[1][0].set_title('STRINGENCY:\n 55-70',weight="bold", fontsize='large')
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

sns.heatmap(comix_overall_weak, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = matrix_max, ax=axs[0][1]).invert_yaxis()
axs[0][1].set_title('STRINGENCY:\n 40-55',weight="bold", fontsize='large')
axs[0][1].set_yticks(ticks=major_ticks)
axs[0][1].set_yticks(ticks=minor_ticks, minor=True)
axs[0][1].set_xticks(ticks=major_ticks)
axs[0][1].set_xticks(ticks=minor_ticks, minor=True)
axs[0][1].tick_params(axis='both', which='major', labelsize=18)
cbar = axs[0][1].collections[0].colorbar
cbar.set_label(label='Contact rate (rescaled)', fontsize=18)
cbar.ax.tick_params(labelsize=18)
cbar.ax.yaxis.offsetText.set_fontsize(18)

sns.heatmap(comix_overall_strongest, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = matrix_max, ax=axs[1][1]).invert_yaxis()
axs[1][1].set_title('STRINGENCY:\n greater than 70',weight="bold", fontsize='large')
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

axs[0][0].text(-2,15.5,'a)', weight='bold', fontsize='large')
axs[0][1].text(-2,15.5,'b)', weight='bold', fontsize='large')
axs[1][0].text(-2,15.5,'c)', weight='bold', fontsize='large')
axs[1][1].text(-2,15.5,'d)', weight='bold', fontsize='large')

axs[1][1].text(-11,-3.25,'Age of Participant (years)', weight='bold', fontsize='x-large')
axs[0][0].text(-3.25,-8.5,'Age of Contact (years)', weight='bold', fontsize='x-large',rotation=90)


plt.savefig('Supplement figure stringency overall.pdf')