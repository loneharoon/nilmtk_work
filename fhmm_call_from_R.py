
# coding: utf-8

# In[ ]:

import warnings
warnings.filterwarnings("ignore")
import fhmm_support as fhm
from hmmlearn import hmm
import numpy as np
np.random.seed(23)
#matplotlib inline
#import matplotlib.pyplot as plt
import os
import pandas as pd
from collections import OrderedDict
import time
#import ipdb


# In[ ]:

def divide_dataset_in_appliances(df):
    agg_meter = df['use']
    meters = df.columns
    #import ipdb;ipdb.set_trace()
    meters = meters.drop('use')
    sub_meters = df[meters]
    return (agg_meter,sub_meters)


# In[ ]:

train_agg_meter,train_sub_meters = divide_dataset_in_appliances(train_dset)
test_agg_meter,test_sub_meters = divide_dataset_in_appliances(test_dset)


# In[ ]:

# train model for each applaince
model = OrderedDict()
appliances = train_sub_meters.columns
for appliance in appliances:
   # print appliance;
    model[appliance] =  hmm.GaussianHMM(n_components=2,covariance_type="full")
    temp =  train_sub_meters[appliance].values.reshape(len(train_sub_meters[appliance]),1)
    model[appliance].fit([temp])
    
# sort all the parameters and update new models with these 
new_learnt_models= OrderedDict()
for appliance in model:
    #print appliance;
    startprob, means, covars, transmat = fhm.sort_learnt_parameters(model[appliance].startprob_, model[appliance].means_, model[appliance].covars_ , model[appliance].transmat_) 
    new_learnt_models[appliance]=hmm.GaussianHMM(startprob.size, "full", startprob, transmat)
    new_learnt_models[appliance].means_ = means
    new_learnt_models[appliance].covars_ = covars

# create aggregate model
learnt_model_combined = fhm.create_combined_hmm(new_learnt_models)

temp1 = test_agg_meter.values.reshape(len(test_agg_meter),1)
#start_time = time.time()
new_learnt_states = learnt_model_combined.predict(temp1)
#print('time taken %f seconds' %(time.time() - start_time))


# In[ ]:

temp_means = OrderedDict()
for app in model:
    temp_means[app] = new_learnt_models[app].means_
[decoded_states, decoded_power] = fhm.decode_hmm(len(new_learnt_states), temp_means, [appliance for appliance in model], new_learnt_states)


# In[ ]:

decoded_power = pd.DataFrame(decoded_power)

