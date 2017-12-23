# -*- coding: utf-8 -*-
"""
This is an extended copied version of demo_latentBayesianMelding.py.
"""

import pandas as pd
import matplotlib.pyplot as plt
from latent_Bayesian_melding import LatentBayesianMelding

############# some global variables ##########################
# Sampling time was 2 minutes
sample_seconds = 120

dir = ""
home = ""
meterdata = pd.read_csv('/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/115.csv',index_col="localminute")
meterdata = meterdata[:"2014-06-05"]



appliance_map = {'cooker': "('cooker', 1)",
                 'kettle': "('kettle', 1)",
                 'dishwasher': "('dish washer', 1)",
                 'toaster': "('toaster', 1)",
                 'washingmachine': "('washing machine', 1)",
                 'fridgefreezer': "('fridge', 1)",
                 'microwave': "('microwave', 1)"}

########### Appliances to be disaggregated: not all of the appliance #########
meterlist = ['air1','furnace1']

## the ground truth reading for those appliances to be disaggregated ########
appliancedata = meterdata
groundTruthApplianceReading = pd.DataFrame(index=meterdata.index)
for meter in appliance_map:
    groundTruthApplianceReading[meter] = meterdata[appliance_map[meter]]
    appliancedata = appliancedata.drop(appliance_map[meter], axis=1)
## the sum of other meter readings which will not be disaggregated
groundTruthApplianceReading['othermeters'] = appliancedata.sum(axis=1)

## The mains readings to be disaggregated ###
mains = meterdata['use']

#### declare an instance for lbm ################################
lbm = LatentBayesianMelding()
# lbm = FHMM_Relaxed()

# to obtain the model parameters trained by using HES data
json_file = "/Volumes/MacintoshHD2/Users/haroonr/Downloads/temp/101.json"
# json_file="/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/reduced.json"
individual_model = lbm.import_model(meterlist, json_file)

# use lbm to disaggregate mains readings into appliances
results = lbm.disaggregate_chunk(mains)

# the inferred appliance readings
infApplianceReading = results['inferred appliance energy']

# compare inferred appliance readings and the ground truth
for meter in meterlist:
    plt.figure()
    ax = groundTruthApplianceReading[meter].plot(legend=True)
    infApplianceReading[meter].plot(ax=ax, title=meter, color='r', legend=True)
    ax.legend(['truth', 'inferred'])
    ax.set_xlabel('time')
    ax.set_ylabel('deciwatt-hour')
plt.figure()
ax = infApplianceReading['mains'].plot(title='mains')
infApplianceReading['inferred mains'].plot(ax=ax, color='r')
ax.legend(['truth', 'inferred'])
ax.set_xlabel('time')
ax.set_ylabel('deciwatt-hour')

# close the file
meterdata_ukdale.close()