import pandas as pd
import numpy as np
from sklearn.cluster import KMeans
from itertools import groupby
import matplotlib.pyplot as plt
import seaborn as sns
from copy import deepcopy

file = "115.csv"
path = "/Volumes/MacintoshHD2/Users/haroonr/Detailed_datasets/Dataport/mix_homes/default/"
execfile("/Volumes/MacintoshHD2/Users/haroonr/Dropbox/nilmtk_work/localize_appliance_support")

df = pd.read_csv(path+file,index_col='localminute')
df.index =  pd.to_datetime(df.index)

# SYNTHETIC ANOMALY CASE
inj_anom_path = "/Volumes/MacintoshHD2/Users/haroonr/Dropbox/R_codesDirectory/R_Codes/Matrix_division/data_injectedanom/115_injected.csv"
df = pd.read_csv(inj_anom_path,index_col='localminute')
df.index =  pd.to_datetime(df.index)
#PERFORM TRAINING
appliance = "refrigerator1"
df_sub = df["2014-06-01":"2014-06-02"]
if df_sub.empty: print('\x1b[6;30;42m' + 'Missing data!' + '\x1b[0m')
dat_app =  df_sub[appliance]
area_stat = appliance_training(dat_app)
# PERFORM TESTING
df_sub2 = df["2014-06-23":"2014-07-30"]
if df_sub2.empty: print('\x1b[6;30;42m' + 'Missing data!' + '\x1b[0m')
dat_app2 =  deepcopy(df_sub2[appliance])
appliance_testing(dat_app2,area_stat)
#PLOTTING
dat = df[appliance]["2014-07-01":"2014-07-30"]
plot_daywise_facet(app_data = dat,ncolumns = 7)
# inserstion case



def appliance_training(dat_app):
    clus_res = cluster_appliance_usage(dat_app)
    rle_vector = [(k,sum(1 for i in g)) for k,g in groupby(clus_res['cluster'])]
    rle_df =  pd.DataFrame(rle_vector,columns=["value","count"])
    unique_labels = np.repeat(range(rle_df.shape[0]),rle_df['count'])
    clus_res['unique_labels'] = unique_labels
    
    # df_pd refers to ara_res in R code
    df_pd = pd.DataFrame(columns=['cluster','magnitude','duration','area'])
    for i in range(np.unique(unique_labels).size):
     temp_obj =  clus_res[unique_labels==i]    
     start_entry = temp_obj.head(1).index
     last_entry = temp_obj.tail(1).index
     duration_mins = ((last_entry-start_entry).total_seconds()/60.)[0]
     mean_usage = round(temp_obj['consump'].mean(),2)
     area_val = np.trapz(y=temp_obj['consump'])
     df_pd.loc[i] =  [np.unique(temp_obj['cluster'])[0],mean_usage,duration_mins,area_val]
    
    area_stat = compute_area_res_statistic(df_pd)
    area_stat = area_stat.sort_values(by='mean_mag',ascending=True)
    area_stat = area_stat.reset_index(drop=True)
    return area_stat

def appliance_testing(dat_app2,area_stat):
    day_dat =    dat_app2.groupby(dat_app2.index.day)
    for key,value in day_dat:
        test_res = cluster_appliance_testing_stage(value)
        test_res = test_res.sort_values(by='mean_mag',ascending=True)
        test_res = test_res.reset_index(drop=True)
        for i in range(area_stat.shape[0]):
            if(test_res.loc[i].mean_area <= area_stat.loc[i].mean_area - 1.5 * area_stat.loc[i].sd_area):
                print " Frequent Anomaly on " + np.unique(value.index.date)[0].strftime('%d/%m/%Y')
            elif(test_res.loc[i].mean_area >= area_stat.loc[i].mean_area + 1.5 * area_stat.loc[i].sd_area):
                print "Elongated Anomaly on " + np.unique(value.index.date)[0].strftime('%d/%m/%Y')


