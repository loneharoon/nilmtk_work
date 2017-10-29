# this file differs from localize_main file only in the perspective that context is added
import warnings
warnings.filterwarnings("ignore")
import numpy as np
import pandas as pd
import os
np.random.seed(123)



# List all houses in a directory
#dir = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default_3months/"
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/localize_fhmm.py")
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/nilmtk_pycharm/localize_appliance_support.py")
#execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/plot_functions.py")
path2 = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/injected_anomalies/"
aggregate_result = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/inter_results/"

#homes = ["115.csv","434.csv","490.csv","1463.csv","3538.csv"]
homes = ["115.csv"]
#file1 ="101.csv"
#houses = [f for f in os.listdir(dir)]
#df = pd.read_csv(dir+houses[6],index_col='localminute') # USE HOUSE (6,115)
for i in range(len(homes)):
#df = pd.read_csv(dir+file1,index_col='localminute')
    df = pd.read_csv(path2+homes[i],index_col='localminute') # INJECTED FILES
    df.index = pd.to_datetime(df.index)

    df = df["2014-06-01":"2014-08-30 23:59:59"]

    res = df.sum(axis=0)
    high_energy_apps = res.nlargest(6).keys() # CONTROL : selects few appliances
    df_new = df[high_energy_apps]
    del df_new['use']# drop stale aggregate column
    df_new['use'] = df_new.sum(axis=1) # create new aggregate column

    train_dset = df_new.truncate(before="2014-06-01", after="2014-06-30 23:59:59")
    test_dset = df_new.truncate(before="2014-07-01", after="2014-08-30 23:59:59")

    # keep tab on context option - creates day and night divison
    train_result = compute_appliance_statistic(train_dset,context=True) # training, using day and night context

    fhmm_result  =  fhmm_decoding(train_dset,test_dset) #
    #plot_actual_vs_decoded(fhmm_result)
    sel_appliances = ["air1","refrigerator1"]
    dis_res = localize_anomalous_appliance(fhmm_result['decoded_power'][sel_appliances],train_result,appliance_count=100,take_context=True) # appliance anomaly detection
    save_path_disresults = aggregate_result + "fhmm/"
    dis_res.to_csv(save_path_disresults+homes[i])