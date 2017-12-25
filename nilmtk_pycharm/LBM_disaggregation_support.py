#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
The functions in this file are called from some other files
Created on Sun Dec 24 15:08:42 2017

@author: haroonr
"""
from latent_Bayesian_melding import LatentBayesianMelding

def lbm_decoder(meterdata,parameters_path,main_meter = "use", filetype = "pkl"): 
    import pickle
    mains = meterdata[main_meter]
    meterlist = meterdata.columns.tolist()
    meterlist.remove(main_meter)
    lbm = LatentBayesianMelding()
    individual_model = lbm.import_model(meterlist, parameters_path,filetype)
    results = lbm.disaggregate_chunk(mains)
    infApplianceReading = results['inferred appliance energy']
    return(infApplianceReadings)