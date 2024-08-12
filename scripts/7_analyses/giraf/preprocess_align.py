#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# %%
import numpy as np
import pandas as pd

pd.options.mode.chained_assignment = None 


def make_lut(filename):
    """
    Preprocessing step. Takes an MSA file from Geneious in and remaps it 
    into a clean look-up table (lut) which can be exported as a CSV.
    
    The CSV can later be used in the main GIRAF routine to map INTERCAAT 
    files against the Consensus sequence.

    @author: raflocal
    @date: 2023-10-13
    """

    # %% MSA File Loading
    
    msa = pd.read_fwf(filename, header=None)    
    msa.rename(columns={0:'protein', 1 :'sequence'}, inplace=True)
    msa.drop(columns=2, inplace=True)
    
        # %%    
    consensus_order = pd.Series(range(0,len(msa['sequence'].iloc[0])))    
    
    # Lookup Table (lut) for mapping consensus residue # to variant residue #
    # Columns:
        # Consensus - consensus residue number
        # 'variant name' - the variant residue number, named for the n_protein
    
    # Note that p starts at 1 here.
    # The consensus sequence MUST be in row 0.
    p = 1;
    lut = pd.DataFrame(data=consensus_order, columns=['consensus'])
    while p <= len(msa)-1:
    #while p <= 2:
        variant = msa['protein'].iloc[p]
        lut[variant] = np.nan
        print('Making LUT for ' + msa['protein'].iloc[p])
        count = 0;
        for m in range(0,len(msa['sequence'].iloc[p])):
            
            # Check if there is a point mutation
            if msa['sequence'].iloc[p][m].isalpha():
                lut[variant].iloc[m] = count
                count = count + 1;
            
            # check if it's same as consensus
            elif msa['sequence'].iloc[p][m] in '.' :
               lut[variant].iloc[m] = count
               count = count + 1;
                
            # check if there's a deletion        
            elif msa['sequence'].iloc[p][m] in '-' :
                continue                
            
        p = p +1
        
    # add 1 to every value so that the residue # starts at 1    
    lut += 1      
    return lut
    
    
