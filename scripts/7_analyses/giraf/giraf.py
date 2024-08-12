#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Graph-based Interface Residue Assessment Function (GIRAF)


Load INTERCAAT output file, parse the interactions.
Build a graph network from it!

Dependencies:
    pandas for INTERCAAT df parsing and creation
    networkx for graph networking
    matplotlib for plotting the figures from the manuscript
    scipy required to calculate ged

This version was forked from the SARS-CoV-2_N_Cytokine_Docking Repository on 2024-08-06
   https://github.com/tuplexyz/SARS-CoV-2_N-Cytokine_Docking/blob/main/giraf/giraf.py

@author: Raf Jaimes, MIT Lincoln Lab
@date: 2024-08-06
@date: 2023-09-07

"""
# %%
import os
import re
import glob

import pandas as pd

import networkx as nx

import matplotlib.pyplot as plt

# %% INTERCAAT File Loading

def parse_intercaat(filename, lut = None):
    """
    Args:
        filename (str): filename of the intercaat text file.
        lut (dataframe): lookup table with consensus sequence information

    Returns:
        interactions_df (pd.DataFrame): interactions dataframe

    """

    df = pd.read_fwf(filename, header=None)
    # the header is variable in length depending on the number of query residues
    # check column [0] for matching string.
    # after this row is all of the query and chain interactions
    idx = df[df[0] == 'Query Chain    |Interacting Chains|'].index[0]
    # the subset is everything after the header, only the interactions
    interactions = df[idx+1:]
    interactions.reset_index(inplace=True)
    
    # The first column now contains 8 columns. It is the most complicated
    # we need to split it up several ways to get all 8 cols out
    first_column = interactions[0].str.split('|', expand=True)
    split_0 = first_column[0].str.split(' ', expand=False)
    split_1 = first_column[1].str.split(' ', expand=False)
    
    # Now remove all the empty spaces
    split_0 = split_0.apply(lambda x: list(filter(None, x)))
    split_1 = split_1.apply(lambda x: list(filter(None, x)))
    
    # qc = query chain (typically, Chain A, e.g. nucleocapsid)
    # ic = interacting chain (typically, Chain B, C, etc. e.g. Cytokine)
    # now start to put everything together in a interactions_df
    interactions_df = pd.DataFrame(columns=['qc_aa', 'qc_res_num', 'qc_chain', 'qc_atomtype',
                                     'ic_aa', 'ic_res_num', 'ic_chain', 'ic_atomtype',
                                     'dist', 'atomclasses'])
    
    interactions_df[['qc_aa', 'qc_res_num', 'qc_chain', 'qc_atomtype']] = pd.DataFrame(data=split_0.tolist())
    interactions_df[['ic_aa', 'ic_res_num', 'ic_chain', 'ic_atomtype']] = pd.DataFrame(data=split_1.tolist())
             
    # dist is back in the 1 column of interactions
    interactions_df['dist'] = interactions[1]
    # atomclasses is back in the 3 column of interactions
    interactions_df['atomclasses'] = interactions[3]
    
    
    # The following section is optional, if you have an MSA lut file.
    # just comment it out and return interactions_df directly as-is
    
    filebase = os.path.basename(filename)
    pattern = re.compile('^.*?(?=_)')
    protein = re.match(pattern,filebase).group(0)  #is the protein/query chain A or B? 0 or 1?
    
    p = 0
    # change qc to ic, for chain B
    interactions_df['ic_map_res_num'] = 0
    for p in range(0, len(interactions_df)):
         interactions_df['ic_map_res_num'].iloc[p] = lut['consensus'].loc[lut[protein]+110 == int(interactions_df['ic_res_num'].iloc[p])]
         p = p + 1
        
    interactions_df['ic_map_res_num'] = interactions_df['ic_map_res_num'].astype(str)
    
    return interactions_df

# %% Graph Network

def generate_graph(interactions_df, variables='just_aa', DIST_CUTOFF=3):     
    """
    Summary: Generate a graph object based on the residue interactions.
    
    Description: You should use a tool like INTERCAAT to find the residue
        interactions first. Then parse those outputs and compile them
        into a dataframe.
    
    Args:
        interactions_df (pd.DataFrame): interactions dataframe

    Returns:
        G (networkx.classes.graph.Graph): output network graph object

    """
    # New Graph
    G = nx.Graph()
    
    # You don't have to add Nodes explicitly, we can just create them
    # implicitly by adding Edges.        
        
    if variables=='all':
        # Uses all the interaction parameters, very busy graphs
        for p in range(0,len(interactions_df)):
            select = interactions_df.iloc[p]
        
            G.add_edges_from(
                [(select['qc_chain'] + select['qc_aa'] + select['qc_res_num'] + select['qc_atomtype'],
                  select['ic_chain'] + select['ic_aa'] + select['ic_res_num'] + select['ic_atomtype'],
                 {'weight' : interactions_df['dist']} )] )      
            
            p = p + 1
    
    elif variables=='no_atoms':
        # Makes the graphs simpler by removing the atom-level interactions
        # Maintains the AAs, residue numbering. Remove weight/distance.
        for p in range(0,len(interactions_df)):
            select = interactions_df.iloc[p]
        
            G.add_edges_from(
                [(select['qc_chain'] + ',' + select['qc_aa'] + select['qc_res_num'] ,
                  select['ic_chain'] + ',' + select['ic_aa'] + select['ic_res_num'] 
                  )] )  
            
            p = p + 1
            
    elif variables=='res_nums':
        # Makes the graphs simpler by removing the atom-level interactions
        # Maintains the AAs, residue numbering. Remove weight/distance.
        
        # modify qc_map_res_num to qc_res_num if you don't have a lut map
        select = interactions_df[['qc_chain', 'ic_chain', 'qc_res_num', 'ic_map_res_num']].loc[interactions_df['dist'].astype(float) < DIST_CUTOFF]
        select.drop_duplicates(inplace=True)
        
        for p in range(0,len(select)):
            rowselect = select.iloc[p]
            qc_node = rowselect['qc_chain'] + ',' + rowselect['qc_res_num'] # here too
            ic_node = rowselect['ic_chain'] + ',' + rowselect['ic_map_res_num'] # or here
                
            G.add_nodes_from(
                [(qc_node, {'label' : qc_node}),
                  (ic_node, {'label' : ic_node})
                  ] )  
            
            G.add_edge(qc_node, ic_node)
            
            p = p + 1
               
            
         # this option doesn't seem to make any sense.   
    elif variables=='just_aa':
        # Simplest graphs. Removes distance parameter, residue#, and atoms.
        # Only retains the AA on Chain A (QC) and AA on Chain B (IC)
        just_aa_df = interactions_df[['qc_chain', 'qc_aa', 'ic_chain', 'ic_aa']]
        just_aa_df.drop_duplicates(inplace=True)
        for p in range(0,len(just_aa_df)):
            rowselect = just_aa_df.iloc[p]         
            
            qc_node = rowselect['qc_chain'] + ',' + rowselect['qc_aa'] # here too
            ic_node = rowselect['ic_chain'] + ',' + rowselect['ic_aa'] 
                                  
            G.add_nodes_from(
                [(qc_node, {'label' : qc_node}),
                  (ic_node, {'label' : ic_node})
                  ] )  
            
            G.add_edge(qc_node, ic_node)
            
            p = p + 1       
            
        
    return G, interactions_df


# %%
def node_subst_cost(node1, node2):
    # check if the nodes are equal, if yes then apply no cost, else apply 1
    if node1['label'] == node2['label']:
        return 0
    return 1

# %% Exploration
from os import listdir

# LUT work
from preprocess_align import make_lut
 
lut = make_lut('HApro97_HA1_filtered_164 alignment.txt')

# Timeout set to 4 sec is approximately equivalent to 20 sec
# Runs much faster. You could try longer timeouts to see if GED minimizes further.
TIMEOUT=4
#TIMEOUT=20
VARIABLES='res_nums'

# %% Calculate all the GEDs for the INTERCAAT results
analysis_dir = '/home/ra29435/Documents/Public_GitHub/Influenza_H5-Antibody_Predictions/data/intercaat/'
# file1 = 'EPI242227__AVFluIgG01.pdb_intercaat.txt'
# ab= 'AVFluIgG01' # set antibody of interest to match file1 above

file1='EPI242227__H5.3.pdb_intercaat.txt'
ab='H5.3'

df1 = parse_intercaat(analysis_dir + file1, lut)
graph1, idf = generate_graph(df1, variables=VARIABLES)


path = os.path.join(analysis_dir, f'*{ab}*')
file_list = glob.glob(path)

# num_ir is the number of interacting residues
haddock_geds = pd.DataFrame(columns=['filename', 'ged','num_ir'])
for file2 in file_list:
    try:
        df2 = parse_intercaat(file2, lut)
        graph2, idf = generate_graph(df2, variables=VARIABLES)
        print(file2)
        one_ged = nx.graph_edit_distance(graph1, graph2, timeout=TIMEOUT, node_subst_cost=node_subst_cost)
        
        # num_ir counting on the N protein
        A_chain=list()
        for key in graph2._node:
             if key.startswith("A"):
                 A_chain.append(key)                 
        num_ir = len(A_chain)
        
        haddock_geds = pd.concat([haddock_geds, pd.DataFrame(data=[[file2, one_ged,num_ir]], columns=['filename', 'ged', 'num_ir'])])
    except:
        print('error with ' + file2)
    finally:
        continue
    
haddock_geds.reset_index(inplace=True)
haddock_geds['basename'] = haddock_geds['filename'].str.split('/', expand=True).iloc[:,8]
haddock_geds['protein'] = haddock_geds['basename'].str.split('_', expand=True).iloc[:,0]
haddock_geds.set_index('protein', inplace=True)
haddock_geds.sort_values(by='protein', ascending=True, inplace=True)
haddock_geds.drop(columns=['index', 'filename', 'basename'], inplace=True)

haddock_geds.to_csv(ab + '__EPI242227.tsv', sep='\t')

# %% Plotting Bars for GEDs

fig = plt.figure(figsize=(40,30))

def get_axis_limits(ax):
    return ax.get_xlim()[0]*-0.5, ax.get_ylim()[1]*1.1

haddock_geds.sort_values(by='ged', inplace=True)
subax1 = plt.subplot(121)
subax1.barh(haddock_geds.index, haddock_geds.ged)
subax1.set_xlabel('HADDOCK - GED from EPI242227')
subax1.set_title('A', loc='left', fontsize=16, fontweight='bold')

#subax1.annotate('A', xy=get_axis_limits(subax1), fontsize=14)

#ax.set_xlim([100, 200])
#ax.set_title(r'Best N <> CXCL12$\beta$ Compared to' '\n' r'SARS-CoV-2-XBB-N <> CXCL12$\beta$')

# Plotting Bars for Number of Interacting Residues

subax2 = plt.subplot(122)
haddock_geds.sort_values(by='num_ir', inplace=True)
subax2.barh(haddock_geds.index, haddock_geds.num_ir)
subax2.set_xlabel(r'# of Interface Residues under 3Å')
#ax.set_xlim([100, 200])
subax2.set_title('B', loc='left', fontsize=16, fontweight='bold')

# Plotting Bars for GEDs

plt.legend()
fig.tight_layout(h_pad=3)

#fig.savefig('GEDs.pdf')


# %% Bipartite Example

analysis_dir = '/home/ra29435/Documents/Public_GitHub/Influenza_H5-Antibody_Predictions/data/intercaat/'
file1 = 'EPI242227__AVFluIgG01.pdb_intercaat.txt'
file2= 'EPI2437377__AVFluIgG01.pdb_intercaat.txt'

df_example1 = parse_intercaat(analysis_dir + file1, lut)  
graph1, idf = generate_graph(df_example1, variables=VARIABLES, DIST_CUTOFF=3)

df_example2 = parse_intercaat(analysis_dir + file2, lut)  
graph2, idf = generate_graph(df_example2, variables=VARIABLES, DIST_CUTOFF=3)

A_chain=list()
for key in graph1._node:
     if key.startswith("A"):
         A_chain.append(key)
         
B_chain=list()
for key in graph1._node:
     if key.startswith("B"):
         B_chain.append(key)

options = {"edgecolors": "tab:gray", "node_size": 2400, "alpha": 0.8}

fig = plt.figure(figsize=(14,6))
subax1 = plt.subplot(121)
nx.draw(graph1, pos=nx.bipartite_layout(graph1, nodes=B_chain, align='horizontal'), with_labels=True, node_color="tab:blue", **options ) 
subax1.set_title(r'(A) AVFluIgG01', fontsize=20)
subax1.text(x=-0.2, y=-1.4, s=r'(B) EPI242227', fontsize=20)

A_chain=list()
for key in graph2._node:
     if key.startswith("A"):
         A_chain.append(key)
         
B_chain=list()
for key in graph2._node:
     if key.startswith("B"):
         B_chain.append(key)

subax2 = plt.subplot(122)
nx.draw(graph2, pos=nx.bipartite_layout(graph2, nodes=B_chain, align='horizontal'), with_labels=True, node_color="tab:red", **options ) 
subax2.set_title(r'(A) AVFluIgG01', fontsize=20)
subax2.text(x=-0.2, y=-1.24, s=r'(B) EPI2437377', fontsize=20)

plt.tight_layout()
#plt.savefig('graph_bipartite.pdf')
