import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import csv
import matplotlib.ticker as tkr

# Read in contact matrices for original/adjusted UK POLYMOD matrices
polymod_in = {}

with open('Output/UK case study/polymod_original.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        polymod_in[row[0]] = [float(h) for h in row[1:]]


polymod = pd.DataFrame(polymod_in, index=list(polymod_in.keys()))

polymod_comix_in = {}

with open('Output/UK case study/polymod_comix_c.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        polymod_comix_in[row[0]] = [float(h) for h in row[1:]]

polymod_comix = pd.DataFrame(polymod_comix_in, index=list(polymod_comix_in.keys()))

polymod_demo_in = {}

with open('Output/UK case study/polymod_demo_d.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        polymod_demo_in[row[0]] = [float(h) for h in row[1:]]

polymod_demo = pd.DataFrame(polymod_demo_in, index=list(polymod_demo_in.keys()))

polymod_full_in = {}

with open('Output/UK case study/polymod_full_cd.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t', quotechar='"')
    reader.__next__()
    for row in reader:
        polymod_full_in[row[0]] = [float(h) for h in row[1:]]

polymod_full = pd.DataFrame(polymod_full_in, index=list(polymod_full_in.keys()))

plt.rcParams.update({'font.size': 14})

# Plot each contact matrix as separate heatmap in grid
fig, axs = plt.subplots(ncols=2, nrows=2, dpi=400, figsize=[15,11.25])


row_max = max([h for j in range(len(polymod.values)) for h in polymod.values[j]] + 
               [h for j in range(len(polymod_comix.values)) for h in polymod_comix.values[j]] + 
               [h for j in range(len(polymod_demo.values)) for h in polymod_demo.values[j]] + 
               [h for j in range(len(polymod_full.values)) for h in polymod_full.values[j]])

major_ticks = list(range(0,16,2))
minor_ticks = list(range(1,14,2))
tick_labels = [str(h) for h in range(0,75,10)]

formatter = tkr.ScalarFormatter(useMathText=True, useOffset=False)
formatter.set_scientific(True)
formatter.set_powerlimits((0, 0))

sns.heatmap(polymod, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row_max, ax=axs[0][0]).invert_yaxis()
axs[0][0].set_ylabel('NO DEMOGRAPHIC ADJUSTMENT\n\n',weight="bold", fontsize='large')
axs[0][0].set_title('NO COMIX AGE \nBRACKETING',weight="bold", fontsize='large')
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

sns.heatmap(polymod_demo, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row_max, ax=axs[1][0]).invert_yaxis()
axs[1][0].set_ylabel('DEMOGRAPHIC ADJUSTMENT\n\n',weight="bold", fontsize='large')
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

sns.heatmap(polymod_comix, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row_max, ax=axs[0][1]).invert_yaxis()
axs[0][1].set_title('COMIX AGE \nBRACKETING',weight="bold", fontsize='large')
axs[0][1].set_yticks(ticks=major_ticks)
axs[0][1].set_yticks(ticks=minor_ticks, minor=True)
axs[0][1].set_xticks(ticks=major_ticks)
axs[0][1].set_xticks(ticks=minor_ticks, minor=True)
axs[0][1].tick_params(axis='both', which='major', labelsize=18)
cbar = axs[0][1].collections[0].colorbar
cbar.set_label(label='Contact rate (rescaled)', fontsize=18)
cbar.ax.tick_params(labelsize=18)
cbar.ax.yaxis.offsetText.set_fontsize(18)

sns.heatmap(polymod_full, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row_max, ax=axs[1][1]).invert_yaxis()
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


diff_1 = polymod - polymod_comix
diff_2 = polymod - polymod_full

# Plot each contact matrix as separate heatmap in grid
fig, axs = plt.subplots(ncols=3, nrows=2, dpi=400, figsize=[15.75,9.25], width_ratios=[0.8,0.8,1])

axs[0][0].set_axis_off()

diff_max = max([h for j in range(len(diff_1.values)) for h in diff_1.values[j]] + 
               [h for j in range(len(diff_2.values)) for h in diff_2.values[j]])

major_ticks = list(range(0,16,2))
minor_ticks = list(range(1,14,2))
tick_labels = [str(h) for h in range(0,75,10)]

formatter = tkr.ScalarFormatter(useMathText=True, useOffset=False)
formatter.set_scientific(True)
formatter.set_powerlimits((0, 0))

sns.heatmap(polymod, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row_max, ax=axs[1][0], cbar=False).invert_yaxis()
axs[1][0].set_ylabel('HOUSEHOLD\nAge of Contact (years)',weight="bold", fontsize='large')
axs[1][0].set_title('POLYMOD\n',weight="bold", fontsize='large')
axs[1][0].set_yticks(ticks=major_ticks)
axs[1][0].set_yticks(ticks=minor_ticks, minor=True)
axs[1][0].set_yticklabels(tick_labels)
axs[1][0].set_xticks(ticks=major_ticks)
axs[1][0].set_xticks(ticks=minor_ticks, minor=True)
axs[1][0].set_xticklabels(tick_labels)
axs[1][0].tick_params(axis='both', which='major', labelsize=18)
# cbar = axs[1][0].collections[0].colorbar
# cbar.set_label(label='Contact rate (rescaled)', fontsize=18)
# cbar.ax.tick_params(labelsize=18)
# cbar.ax.yaxis.offsetText.set_fontsize(18)

sns.heatmap(polymod_comix, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row_max, ax=axs[0][1], cbar=False).invert_yaxis()
axs[0][1].set_ylabel('HOUSEHOLD\nAge of Contact (years)',weight="bold", fontsize='large')
axs[0][1].set_title('POLYMOD ADJUSTED USING\n COMIX AGE BRACKETS\n',weight="bold", fontsize='large')
axs[0][1].set_yticks(ticks=major_ticks)
axs[0][1].set_yticks(ticks=minor_ticks, minor=True)
axs[0][1].set_yticklabels(tick_labels)
axs[0][1].set_xticks(ticks=major_ticks)
axs[0][1].set_xticks(ticks=minor_ticks, minor=True)
# axs[0][1].set_xticklabels(tick_labels)
axs[0][1].tick_params(axis='both', which='major', labelsize=18)
# cbar = axs[0][1].collections[0].colorbar
# cbar.set_label(label='Contact rate (rescaled)', fontsize=18)
# cbar.ax.tick_params(labelsize=18)
# cbar.ax.yaxis.offsetText.set_fontsize(18)

sns.heatmap(polymod_full, cmap="YlGnBu", cbar_kws={"format": formatter}, vmin=0, vmax = row_max, ax=axs[0][2]).invert_yaxis()
axs[0][2].set_title('POLYMOD ADJUSTED USING\n COMIX AGE BRACKETS &\n DEMOGRAPHIC CHANGE\n',weight="bold", fontsize='large')
axs[0][2].set_yticks(ticks=major_ticks)
axs[0][2].set_yticks(ticks=minor_ticks, minor=True)
axs[0][2].set_xticks(ticks=major_ticks)
axs[0][2].set_xticks(ticks=minor_ticks, minor=True)
axs[0][2].tick_params(axis='both', which='major', labelsize=18)
cbar = axs[0][2].collections[0].colorbar
cbar.set_label(label='Contact rate (rescaled)', fontsize=18)
cbar.ax.tick_params(labelsize=18)
cbar.ax.yaxis.offsetText.set_fontsize(18)

sns.heatmap(diff_1, cmap="RdBu", cbar_kws={"format": formatter}, 
            center = 0, vmin = -1 * diff_max,  vmax = diff_max, ax=axs[1][1], cbar=False).invert_yaxis()
axs[1][1].set_xlabel('Age of Participant (years)',weight="bold", fontsize='large')
axs[1][1].set_yticks(ticks=major_ticks)
axs[1][1].set_yticks(ticks=minor_ticks, minor=True)
axs[1][1].set_xticks(ticks=major_ticks)
axs[1][1].set_xticks(ticks=minor_ticks, minor=True)
axs[1][1].set_xticklabels(tick_labels)
axs[1][1].tick_params(axis='both', which='major', labelsize=18)
# cbar = axs[1][1].collections[0].colorbar
# cbar.set_label(label='Contact rate (rescaled)', fontsize=18)
# cbar.ax.tick_params(labelsize=18)
# cbar.ax.yaxis.offsetText.set_fontsize(18)

sns.heatmap(diff_2, cmap="RdBu", cbar_kws={"format": formatter}, 
            center = 0, vmin = -1 * diff_max,  vmax = diff_max, ax=axs[1][2]).invert_yaxis()
axs[1][2].set_yticks(ticks=major_ticks)
axs[1][2].set_yticks(ticks=minor_ticks, minor=True)
axs[1][2].set_xticks(ticks=major_ticks)
axs[1][2].set_xticks(ticks=minor_ticks, minor=True)
axs[1][2].set_xticklabels(tick_labels)
axs[1][2].tick_params(axis='both', which='major', labelsize=18)
cbar = axs[1][2].collections[0].colorbar
cbar.set_label(label='$\Delta$[ORIGINAL - ADJUSTED]', fontsize=18)
cbar.ax.tick_params(labelsize=18)
cbar.ax.yaxis.offsetText.set_fontsize(18)

axs[0][1].text(-0.75,15.25,'a)', weight='bold', fontsize='large')
axs[0][2].text(-0.75,15.25,'b)', weight='bold', fontsize='large')
axs[1][0].text(-0.75,15.25,'c)', weight='bold', fontsize='large')
axs[1][1].text(-0.75,15.25,'d)', weight='bold', fontsize='large')
axs[1][2].text(-0.75,15.25,'e)', weight='bold', fontsize='large')

# axs[1][1].text(-11,-3.25,'Age of Participant (years)', weight='bold', fontsize='x-large')
# axs[1][0].text(-3.25,-8.5,'Age of Contact (years)', weight='bold', fontsize='x-large',rotation=90)

plt.subplots_adjust(wspace=0.1, hspace=0.1)

plt.savefig('Figure 5.pdf')