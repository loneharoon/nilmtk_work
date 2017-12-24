#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
The functions in this file are called from some other files
Created on Sun Dec 24 15:08:42 2017

@author: haroonr
"""

lbm_decoder(test_dset,parameters_path,main_meter = "use", filetype = "pkl")

mains = meterdata['use']

meterlist = test_dset.columns
lbm = LatentBayesianMelding()
individual_model = lbm.import_model(meterlist, parameters_path,filetype)
results = lbm.disaggregate_chunk(mains)
infApplianceReading = results['inferred appliance energy']
return(infApplianceReadings)