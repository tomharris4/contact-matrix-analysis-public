import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import csv

# Total number of contact surveys
total = 33

# Country names
countryX = []

# Read in cluster assignments
cluster_overall_in = []

with open('Output/output_cluster.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter=',', quotechar='"')
    reader.__next__()
    for row in reader:
        cluster_overall_in.append(int(row[2]))
        countryX.append(row[1])



cluster_overall = pd.DataFrame(cluster_overall_in, columns=['cluster'])

cluster_overall['country'] = countryX

cluster_overall = cluster_overall.set_index('country')

#Number of clusters=3
cluster_map = {cluster_overall['cluster'].get('United Kingdom (P)'): 1, 
               cluster_overall['cluster'].get('United Kingdom (C)'): 2,
               cluster_overall['cluster'].get('China (Wuhan), 2019'): 3}



cluster_overall['cluster'] = [cluster_map[h] for h in cluster_overall['cluster']]

countryX = [countryX[c] + ' [' + str(cluster_overall['cluster'][c]) + ']' for c in range(0,len(countryX))]


cluster_overall['country'] = countryX

cluster_overall = cluster_overall.set_index('country')

# Read in similarity values
sim = []

with open('Output/output_similarity.csv', newline='\n') as csvfile:
    reader = csv.reader(csvfile, delimiter=',', quotechar='"')
    reader.__next__()
    for row in reader:
        sim.append(float(row[3]))


sim = [sim[i:i + total] for i in range(0, len(sim), total)]

sim_overall = pd.DataFrame(sim, index = countryX, columns = countryX)


# Reorder clusters for within-group similarity

country_wg_sim = []

for i in countryX:
    groupi = cluster_overall['cluster'].get(i)

    wg_sim = 0
    
    for j in countryX:
        groupj = cluster_overall['cluster'].get(j)

        if (groupi == groupj):
            wg_sim += sim_overall[j].get(i)
    
    country_wg_sim.append(wg_sim)

cluster_overall['wg_sim'] = country_wg_sim


cluster_overall = cluster_overall.sort_values(by=['cluster','wg_sim'])

col_reorder = list(cluster_overall.index)


sim_overall = sim_overall[col_reorder]


sim_overall = sim_overall.reindex(col_reorder)

# Plot heatmap

sns.set(font_scale=1.5)
fig = plt.figure(figsize=[15,12])
axs = plt.axes()



sns.heatmap(sim_overall, cmap="YlGnBu",  ax=axs).invert_yaxis()

cbar = axs.collections[0].colorbar
cbar.set_label('Distance (KL divergence)',rotation=270,labelpad=20, fontsize=20)
cbar.ax.tick_params(labelsize=20)


g1 = 12
g2 = 17
g3 = 4

# group 1
axs.axhline(0.05, xmin=0, xmax=g1/total,linestyle='-', color='red')
axs.axhline(g1, xmin=0, xmax=g1/total,linestyle='-', color='red')
axs.axvline(0.05, ymin=0, ymax=g1/total,linestyle='-', color='red')
axs.axvline(g1, ymin=0, ymax=g1/total,linestyle='-', color='red')

# group 2
axs.axhline(g1, xmin=g1/total, xmax=(g1+g2)/total,linestyle='-', color='red')
axs.axhline(g1+g2, xmin=g1/total, xmax=(g1+g2)/total,linestyle='-', color='red')
axs.axvline(g1, ymin=g1/total, ymax=(g1+g2)/total,linestyle='-', color='red')
axs.axvline(g1+g2, ymin=g1/total, ymax=(g1+g2)/total,linestyle='-', color='red')

# group 3
axs.axhline(g1+g2, xmin=(g1+g2)/total, xmax=((g1+g2+g3)/total),linestyle='-', color='red')
axs.axhline(g1+g2+g3-0.025, xmin=(g1+g2)/total, xmax=((g1+g2+g3)/total),linestyle='-', color='red')
axs.axvline(g1+g2, ymin=(g1+g2)/total, ymax=((g1+g2+g3)/total),linestyle='-', color='red')
axs.axvline(g1+g2+g3-0.025, ymin=(g1+g2)/total, ymax=((g1+g2+g3)/total),linestyle='-', color='red')


plt.tight_layout()
# plt.savefig('Figure 2 (seaborn).pdf')