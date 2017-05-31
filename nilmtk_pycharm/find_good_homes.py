# this file differs from localize_main file only in the perspective that context is added
import warnings
warnings.filterwarnings("ignore")
import numpy as np
import pandas as pd
import os
np.random.seed(123)

dir = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default3/"
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/localize_fhmm.py")
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/localize_appliance_support.py")

houses = [f for f in os.listdir(dir)]

for i in range(213,300): # CHECKED TILL 300
    df = pd.read_csv(dir+houses[i],index_col='localminute')
    df.index = pd.to_datetime(df.index)

    df = df["2014-06-01":"2014-08-30 23:59:59"]
    res = df.sum(axis=0)
    high_energy_apps = res.nlargest(6).keys() # CONTROL : selects few appliances
    df_new = df[high_energy_apps]
    del df_new['use']# drop stale aggregate column
    df_new['use'] = df_new.sum(axis=1) # create new aggregate column

    train_dset = df_new.truncate(before="2014-06-01", after="2014-06-30 23:59:59")
    test_dset = df_new.truncate(before="2014-07-01", after="2014-07-30 23:59:59")

    fhmm_result  =  fhmm_decoding(train_dset,test_dset)
    print "HOUSE NO " + houses[i] + "::"+ str(i)
    print accuracy_metric_norm_error(fhmm_result)