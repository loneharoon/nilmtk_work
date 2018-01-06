""" function in this file are called from localize_main.py"""
from sklearn.cluster import KMeans
from itertools import groupby
from copy import deepcopy

def cluster_appliance_testing_stage(test_dat,device):
    """runs over the appliances outtput from NILM stage
    test_dat: is time_series power consumption data
    """
    data_arr = test_dat.values
    temp = pd.DataFrame(data_arr)
    if(device=="air1"):
        kmeans_ob =  KMeans(n_clusters=2).fit(data_arr.reshape(-1,1)) # AC
    else:
        kmeans_ob =  KMeans(n_clusters=2).fit(data_arr.reshape(-1,1)) # fridge
    temp['cluster'] = kmeans_ob.labels_
    temp.columns = ['consump','cluster']
    rle_vector = [(k,sum(1 for i in g)) for k,g in groupby(temp['cluster'])]
    rle_df =  pd.DataFrame(rle_vector,columns=["value","count"])
    unique_labels = np.repeat(range(rle_df.shape[0]),rle_df['count'])
    temp['unique_labels'] = unique_labels
    temp.index = test_dat.index

    df_pd = pd.DataFrame(columns=['cluster','magnitude','duration','area'])
    for i in range(np.unique(unique_labels).size):
        temp_obj =  temp[unique_labels==i]
        start_entry = temp_obj.head(1).index
        last_entry = temp_obj.tail(1).index
        duration_mins = ((last_entry-start_entry).total_seconds()/60.)[0]
        mean_usage = round(temp_obj['consump'].mean(),2)
        area_val = np.trapz(y=temp_obj['consump'])
        df_pd.loc[i] =  [np.unique(temp_obj['cluster'])[0],mean_usage,duration_mins,area_val]
    area_stat = compute_area_res_statistic(df_pd)
    return(area_stat)

def cluster_appliance_testing_stage_with_time_context(test_dat, device):
    """runs over the appliances outtput from NILM stage
    test_dat: is time_series power consumption data
    """
    # from IPython import embed
    # embed()
    hour = test_dat.index.hour
    selector = ((hour >= 0) & (hour <= 6)) | (hour >= 18) # night data selection
    night_data = test_dat[selector]
    day_data = test_dat.between_time('6:00', '18:00')
    data_contexts = {'day': day_data, 'night': night_data}
    context_result = {}
    for key, value in data_contexts.iteritems():
        data_arr = value.values
        temp = pd.DataFrame(data_arr)
        if (device == "air1"):
            kmeans_ob = KMeans(n_clusters=2).fit(data_arr.reshape(-1, 1))  # AC
        else:
            #print data_arr.reshape(-1,1)
            kmeans_ob = KMeans(n_clusters=2).fit(data_arr.reshape(-1, 1))  # fridge
        # kmeans_ob =  KMeans(n_clusters=2).fit(data_arr.reshape(-1,1))
        temp['cluster'] = kmeans_ob.labels_
        temp.columns = ['consump', 'cluster']
        #FIXME changed following lines while finding that sometimes cluster labels are not properly assinged
        if temp.iloc[temp['consump'].idxmax(axis=0)]['cluster'] == 0:
            temp['cluster'] = temp['cluster'].map({1.00: 0, 0.00: 1})
            print 'changed cluster labels'
        rle_vector = [(k, sum(1 for i in g)) for k, g in groupby(temp['cluster'])]
        rle_df = pd.DataFrame(rle_vector, columns=["value", "count"])
        unique_labels = np.repeat(range(rle_df.shape[0]), rle_df['count'])
        temp['unique_labels'] = unique_labels
        temp.index = value.index
        df_pd = pd.DataFrame(columns=['cluster', 'magnitude', 'duration', 'area'])
        for i in range(np.unique(unique_labels).size):
            temp_obj = temp[unique_labels == i]
            start_entry = temp_obj.head(1).index
            last_entry = temp_obj.tail(1).index
            #duration_mins = ((last_entry - start_entry).total_seconds() / 60.)[0]
            duration_mins = temp_obj.shape[0]
            mean_usage = round(temp_obj['consump'].mean(), 2)
            area_val = np.trapz(y=temp_obj['consump'])
            #print device + ":" + key + ":" + str(i) + ":" + str(area_val)
            df_pd.loc[i] = [np.unique(temp_obj['cluster'])[0], mean_usage, duration_mins, area_val]
        #print "Before compute_area_res_statistic"
        #print df_pd
        temp_res = compute_area_res_statistic(df_pd,device,key)
        temp_res = temp_res.sort_values(by='mean_mag', ascending=True)
        temp_res = temp_res.reset_index(drop=True)
        #print "after compute_area_res_statistic"
        #print temp_res
        context_result[key] = temp_res
    return (context_result)

def cluster_appliance_usage(dat_app,appliance):
    """ performs clustering on consumption values. returns clustering label for each value
    """
    data_arr = dat_app.values
    temp = pd.DataFrame(data_arr)
    if('appliance'=='air1'):
        kmeans_ob =  KMeans(n_clusters = 2).fit(data_arr.reshape(-1,1)) # AC
    else:
        kmeans_ob =  KMeans(n_clusters = 2).fit(data_arr.reshape(-1,1)) # Refrigerator
    temp['cluster'] = kmeans_ob.labels_
    temp.columns = ['consump','cluster']
    # FIXME changed following lines while finding that sometimes cluster labels are not properly assinged
    if temp.iloc[temp['consump'].idxmax(axis=0)]['cluster'] == 0:
        temp['cluster'] = temp['cluster'].map({1.00: 0, 0.00: 1})
        print 'changed cluster labels'
    temp.index = dat_app.index
    #from IPython import embed
    #embed()
    return temp

def appliance_area_statistic(dat,appliance):
    """ called by fucntion compute_appliance_statistic at training stage"""
    #df_sub = df["2014-06-10":"2014-06-14"]
    dat_app =  dat
    #from IPython import embed
    #embed()
    clus_res = cluster_appliance_usage(dat_app,appliance)
    rle_vector = [(k,sum(1 for i in g)) for k,g in groupby(clus_res['cluster'])]
    rle_df =  pd.DataFrame(rle_vector,columns=["value","count"])
    unique_labels = np.repeat(range(rle_df.shape[0]),rle_df['count'])
    clus_res['unique_labels'] = unique_labels
    #df_pd refers to araa_res in R code
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
    return(area_stat)

def appliance_area_statistic_with_time_context(dat, appliance):
    """ called by function compute_appliance_statistic at training stage. This variant is used when we want to use time context"""
    # df_sub = df["2014-06-10":"2014-06-14"]
    # dat_app =  dat
    # dat  = dat['air1']
    hour = dat.index.hour
    selector = ((hour >= 0) & (hour <= 6)) | (hour >= 18)
    night_data = dat[selector]
    day_data = dat.between_time('6:00', '18:00')
    data_contexts = {'day': day_data, 'night': night_data}
    context_result = {}
    for key, value in data_contexts.iteritems():  # no. of contexts, corrently we have only day and night
        clus_res = cluster_appliance_usage(value, appliance)
        rle_vector = [(k, sum(1 for i in g)) for k, g in groupby(clus_res['cluster'])]
        rle_df = pd.DataFrame(rle_vector, columns=["value", "count"])
        unique_labels = np.repeat(range(rle_df.shape[0]), rle_df['count'])
        clus_res['unique_labels'] = unique_labels
        # df_pd refers to araa_res in R code
        df_pd = pd.DataFrame(columns=['cluster', 'magnitude', 'duration', 'area'])
        for i in range(np.unique(unique_labels).size):
            temp_obj = clus_res[unique_labels == i]
            start_entry = temp_obj.head(1).index
            last_entry = temp_obj.tail(1).index
            #duration_mins = ((last_entry - start_entry).total_seconds() / 60.)[0]
            duration_mins = temp_obj.shape[0]
            mean_usage = round(temp_obj['consump'].mean(), 2)
            area_val = np.trapz(y=temp_obj['consump'])
            df_pd.loc[i] = [np.unique(temp_obj['cluster'])[0], mean_usage, duration_mins, area_val]
        area_stat = compute_area_res_statistic(df_pd,appliance,key)
        area_stat = area_stat.sort_values(by='mean_mag', ascending=True)
        area_stat = area_stat.reset_index(drop=True)
        context_result[key] = area_stat
    return (context_result)

def appliance_anomaly_result(test_day, area_stat, device, take_context):  # area_stat stores training models results
    """ function called by localize_anomalous_appliance,used at testing time.
     It works at day level data for each appliance separately"""
    # print "start:"+device+":"+test_day.index.date[0].strftime('%d/%m/%Y')

    if take_context:
        test_res = cluster_appliance_testing_stage_with_time_context(test_day, device)
        area_stat = area_stat[device]
        df = pd.DataFrame()# for storing results
        air_status = 0
        refrigerator_status = 0
        if device == "air1":
            air_status = 1
        else:
            refrigerator_status = 1
        for key, context in area_stat.iteritems():
            test = test_res[key]  # area_stat -> context,test_res - > test

            for i in range(context.shape[0]):  # for no. of rows corresponding to no.of clusters/states
                states = test.shape[0]-1 #no. of states found during clustering in the concerned data
                if i > states:
                    print "state "+str(i)+" is not in "+device + " on " + np.unique(test_day.index.date)[0].strftime(
                        '%d/%m/%Y') + " at " + key + " time"
                    continue
                if (test.loc[i].mean_area <= context.loc[i].mean_area - 1.0 * context.loc[i].sd_area):
                    if test.loc[i].mean_mag < 20: #ignore off states. short off states gives false provides. These are opposite of long on states
                        continue
                    print device + " Frequent Anomaly on " + np.unique(test_day.index.date)[0].strftime(
                        '%d/%m/%Y') + " at " + key + " time"
                    anom_type = "frequent"
                    df = df.append({'Date': np.unique(test_day.index.date)[0].strftime(
                        '%Y-%m-%d'), 'air1': air_status, 'refrigerator1': refrigerator_status, 'context': key,
                        'Anom_type': anom_type,'Magnitude':test.loc[i].mean_mag}, ignore_index=True)
                elif (test.loc[i].mean_area >= context.loc[i].mean_area + 1.0 * context.loc[i].sd_area):
                    if test.loc[i].mean_mag < 20: #ignore off states. short off states gives false provides. These are opposite of long on states
                        continue
                    print device + " Elongated Anomaly on " + np.unique(test_day.index.date)[0].strftime(
                        '%d/%m/%Y') + " at " + key + " time"
                    anom_type = "elongated"
                    df = df.append({'Date': np.unique(test_day.index.date)[0].strftime(
                        '%Y-%m-%d'), 'air1': air_status, 'refrigerator1': refrigerator_status, 'context': key,
                        'Anom_type': anom_type,'Magnitude':test.loc[i].mean_mag}, ignore_index=True)
        return df
    else:
        test_res = cluster_appliance_testing_stage(test_day, device)
        test_res = test_res.sort_values(by='mean_mag', ascending=True)
        test_res = test_res.reset_index(drop=True)
        area_stat = area_stat[device]
        for i in range(area_stat.shape[0]):
            if (test_res.loc[i].mean_area <= area_stat.loc[i].mean_area - 1.5 * area_stat.loc[i].sd_area):
                print device + "Frequent Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y')
            elif (test_res.loc[i].mean_area >= area_stat.loc[i].mean_area + 1.5 * area_stat.loc[i].sd_area):
                print device + "Elongated Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y')

def appliance_anomaly_result_version2(test_day,area_stat,take_context): # area_stat stores training models results
    """this variant is used when we have only one appliance """
    if take_context:
        print "I am inside context"
        test_res = cluster_appliance_testing_stage_with_time_context(test_day,"input_appliance")
        for key,context in area_stat.iteritems():
            test = test_res[key] # area_stat -> context,test_res - > test
            for i in range(context.shape[0]): # for no. of rows corresponding to no.of clusters/states
                if(test.loc[i].mean_area <= context.loc[i].mean_area - 1.5 * context.loc[i].sd_area):
                    print " Frequent Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y') +" at "+ key + " time"
                elif(test.loc[i].mean_area >= context.loc[i].mean_area + 1.5 * context.loc[i].sd_area):
                    print " Elongated Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y') +" at "+ key + " time"
    else:
        print "I am inside NON-context"
        test_res = cluster_appliance_testing_stage(test_day,"input_appliance")
        test_res = test_res.sort_values(by='mean_mag',ascending=True)
        test_res = test_res.reset_index(drop=True)
        #area_stat = area_stat
        for i in range(area_stat.shape[0]):
            if(test_res.loc[i].mean_area <= area_stat.loc[i].mean_area - 1.5 * area_stat.loc[i].sd_area):
                print "Frequent Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y')
            elif(test_res.loc[i].mean_area >= area_stat.loc[i].mean_area + 1.5 * area_stat.loc[i].sd_area):
                print "Elongated Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y')



    # m1 = map(str, train_dset.index.strftime('%m'))  # month
    # d1 = map(str, train_dset.index.strftime('%d'))  # days
    # import operator
    # ind1 = map(operator.add, m1, d1)  # create key using combination

def appliance_anomaly_result_test_func(test_day, area_stat, device, take_context):  # area_stat stores training models results
    """ function called by localize_anomalous_appliance,used at testing time.
     It works at day level data for each appliance separately.
     In minute level data: Sd were set as (1,1),(1,2),(1.5)
     In second level data: SD were set as (1,1),(1.5,2.5),(2)"""
    if take_context:
        print "start:" + device + ":" + test_day.index.date[0].strftime('%d/%m/%Y')
        test_res = cluster_appliance_testing_stage_with_time_context(test_day, device)
        area_stat = area_stat[device]
        df = pd.DataFrame()# for storing results
        air_status = 0
        refrigerator_status = 0
        if device == "air1":
            air_status = 1
        else:
            refrigerator_status = 1
        for key, context in area_stat.iteritems():
            test = test_res[key]  # corresponding context data from test day
            #FIXME  TUNABLE PARAMETERS ARE PRESENT HERE
            #for i in range(context.shape[0]):  # for no. of rows corresponding to no.of clusters/states
            states = test.shape[0]-1 #no. of states found during clustering in the concerned data
            train_states = context.shape[0] - 1  # no. of states found during clustering in the concerned data
            print context
            print test
            if train_states == 0:  # device remained off for full day
                print "Appliance training shows it has only one state! hence quiting"
                continue
            if states == 0: # device remained off for full day
                print "state " + str(1) + " is not in " + device + " on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y') + " at " + key + " time"
                continue
            #print test.loc[1].mean_area
            #print test.loc[0].mean_area
            #print context.shape[0]
            #print context.loc[1].mean_area
            if ((test.loc[0].mean_area <= abs(context.loc[0].mean_area - 1.0 * context.loc[0].sd_area)) & (test.loc[1].mean_area <= abs(context.loc[1].mean_area - 1.0 * context.loc[1].sd_area))):
                #print "frequent case"
                print device + " Frequent Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y') + " at " + key + " time"
                anom_type = "frequent"
                df = df.append({'Date': np.unique(test_day.index.date)[0].strftime(
                    '%Y-%m-%d'), 'air1': air_status, 'refrigerator1': refrigerator_status, 'context': key,
                    'Anom_type': anom_type, 'Magnitude': test.loc[1].mean_mag}, ignore_index=True)
            elif ((test.loc[1].mean_area >= context.loc[1].mean_area + 1.5 * context.loc[1].sd_area) & (test.loc[0].mean_duration > 2.5 * context.loc[0].mean_duration)):
                #"when person was out for long time and then suddenly he used ac is not an anomaly"
                print device + " Not Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y') + " at " + key + " time"
                continue
            elif (test.loc[1].mean_area >= context.loc[1].mean_area + 2.0 * context.loc[1].sd_area):
                #print "elongated case"
                print device + " Elongated Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y') + " at " + key + " time"
                anom_type = "elongated"
                df = df.append({'Date': np.unique(test_day.index.date)[0].strftime(
                    '%Y-%m-%d'), 'air1': air_status, 'refrigerator1': refrigerator_status, 'context': key,
                    'Anom_type': anom_type, 'Magnitude': test.loc[1].mean_mag}, ignore_index=True)

        return df
    else:
        test_res = cluster_appliance_testing_stage(test_day, device)
        test_res = test_res.sort_values(by='mean_mag', ascending=True)
        test_res = test_res.reset_index(drop=True)
        area_stat = area_stat[device]
        for i in range(area_stat.shape[0]):
            if (test_res.loc[i].mean_area <= area_stat.loc[i].mean_area - 1.5 * area_stat.loc[i].sd_area):
                print device + "Frequent Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y')
            elif (test_res.loc[i].mean_area >= area_stat.loc[i].mean_area + 1.5 * area_stat.loc[i].sd_area):
                print device + "Elongated Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y')


def appliance_area_statistic_with_time_context(dat, appliance):
    """ called by function compute_appliance_statistic at training stage. This variant is used when we want to use time context"""
    # df_sub = df["2014-06-10":"2014-06-14"]
    # dat_app =  dat
    # dat  = dat['air1']
    hour = dat.index.hour
    selector = ((hour >= 0) & (hour <= 6)) | (hour >= 18)
    night_data = dat[selector]
    day_data = dat.between_time('6:00', '18:00')
    data_contexts = {'day': day_data, 'night': night_data}
    context_result = {}
    for key, value in data_contexts.iteritems():  # no. of contexts, currently we have only day and night
        clus_res = cluster_appliance_usage(value, appliance) # provides cluster label for each observation
        rle_vector = [(k, sum(1 for i in g)) for k, g in groupby(clus_res['cluster'])] # like rle() in r. Here I save each in tuple form
        rle_df = pd.DataFrame(rle_vector, columns=["value", "count"])
        unique_labels = np.repeat(range(rle_df.shape[0]), rle_df['count'])
        clus_res['unique_labels'] = unique_labels
        df_pd = pd.DataFrame(columns=['cluster', 'magnitude', 'duration', 'area'])
        for i in range(np.unique(unique_labels).size):
            temp_obj = clus_res[unique_labels == i]
            start_entry = temp_obj.head(1).index
            last_entry = temp_obj.tail(1).index
            #duration_mins = ((last_entry - start_entry).total_seconds() / 60.)[0] # no. of minutes this state remained
            duration_mins = temp_obj.shape[0] # No. of observations equals to number of minutes. Changed while aiwe was creating some issue
            mean_usage = round(temp_obj['consump'].mean(), 2)
            area_val = np.trapz(y=temp_obj['consump'])
            df_pd.loc[i] = [np.unique(temp_obj['cluster'])[0], mean_usage, duration_mins, area_val]
        area_stat = compute_area_res_statistic(df_pd,appliance,key)
        area_stat = area_stat.sort_values(by='mean_mag', ascending=True)
        area_stat = area_stat.reset_index(drop=True)
        context_result[key] = area_stat
    return (context_result)

def localize_anomalous_appliance(fhmm_result, train_result, appliance_count, take_context):
    """ Required at testing time
    input: fhmm_result -  disaggregated appliance data and; train_result - the appliance statistics/models from training data
    input : appliance_count: this parameter decides if we have one appliance or more than one. for one appliance this should be
    1 , and for rest any value will suffice. Basically using this parameter we call different functions
    output:find whether appliance is anomalous on day basis"""
    test_temp = deepcopy(fhmm_result)
    m = map(str, test_temp.index.strftime('%m'))  # month
    d = map(str, test_temp.index.strftime('%d'))  # days
    import operator
    ind = map(operator.add, m, d)  # create key using combination
    day_dat = test_temp.groupby(ind)
    result = []
    for key, value in day_dat:  # day level slicing
        daydat_temp = value
        #print 'stage1'
        if appliance_count == 1:  # of only one appliance, then appliance slicing level not required
            appliance_anomaly_result_version2(daydat_temp, train_result, take_context)
        else:
            # case when appliance level slicing required
            appliances = daydat_temp.columns
            #print 'stage2'
            for i in range(len(appliances)):  # appliance level slicing
               if any(daydat_temp[appliances[i]]):
                    # FIXME select proper function
                    result.append(appliance_anomaly_result_test_func(daydat_temp[appliances[i]], train_result, appliances[i], take_context))
               else:
                   print 'stage__continue'
                   continue
    final_result = pd.concat(result)
    return final_result



def insert_anomaly_in_testframe(test_dset,anomalies,appliance_name):
    """  This function inserts anomalies provided in input anomalies dictionary in the applaiance_name column of
    pandas test_dset dataframe"""
    import sys
    test_data = deepcopy(test_dset)
    change_columns = test_data[["use",appliance_name]] # cols. to play with
    retain_columns = test_data.drop(["use",appliance_name],axis=1) # as such columns
    change_columns["use"] = change_columns["use"] - change_columns[appliance_name]
    # insert anomalies in data
    for key,value in anomalies.iteritems():
     change_columns[appliance_name][value.index] = value.values
     # update aggregate usage
    change_columns["use"] = change_columns["use"] + change_columns[appliance_name]
    # munge data frame agaim
    updated_df = pd.concat([retain_columns,change_columns],axis=1)
    if(test_data.shape != updated_df.shape):
        sys.exit("Anomaly insertion did not happen correctly")
    return (updated_df)

def insert_anomaly_in_appliance(test_dset,anomalies,appliance_name):
    """one columns of dataframe is extracted completely and then anomalies are inserted """
    import sys
    data = deepcopy(test_dset[appliance_name].to_frame())
    for key,value in anomalies.iteritems():
        data[appliance_name][value.index] = value.values
    return (data)

def compute_appliance_statistic(train_data, context=False):
    """ works on training data, i.e. creates one time statistic corresponding to appliances in a home;
    Return: dictionary corresponding to each appliance"""
    train_temp = deepcopy(train_data)
    if ('use' in train_data.columns):
        del train_temp['use']
    appliances = train_temp.columns
    app_result = {}
    for i in range(len(appliances)):
        if (context):
            app_result[appliances[i]] = appliance_area_statistic_with_time_context(train_temp[appliances[i]],
                                                                                   appliances[i])
        else:
            app_result[appliances[i]] = appliance_area_statistic(train_temp[appliances[i]], appliances[i])
    return (app_result)

def compute_rmse(gt,pred):
    from sklearn.metrics import mean_squared_error
    rms_error = {}
    for app in gt.columns:
        rms_error[app] =  np.sqrt(mean_squared_error(gt[app],pred[app]))
    return pd.Series(rms_error)

def compute_area_res_statistic(area_res,appliance,key):
    """ computes various statistic corresponding to each state/cluster """
    dframe = pd.DataFrame(columns=['cluster', 'mean_mag', 'mean_duration', 'mean_area', 'sd_area'])
    for i in range(np.unique(area_res['cluster']).size):
        temp = area_res.loc[area_res['cluster'] == i]

        dframe.loc[i] = [i, temp['magnitude'].mean(), temp['duration'].mean(), temp['area'].mean(), temp['area'].std()]
        #dframe.loc[i] = [i, temp['magnitude'].median(), temp['duration'].median(), temp['area'].median(), temp['area'].std()]
        #FIXME : YOU CAN TUNE ABOVE LINE
        #print dframe.loc[i]
    return (dframe)

def diss_accu_metric_kotler_1(dis_result,aggregate):
    #dis_result = co_result
    pred = dis_result['decoded_power']
    gt = dis_result['actaul_power']
    error = []
    numerator = 0
    for app in gt.columns:
        numerator = numerator + sum(abs(pred[app].values - gt[app].values))
    denominator = aggregate*1.0 # to make it float
    #return (1 - (numerator / denominator))
    return(1-2*(numerator/denominator))

def diss_accu_metric_kotler_2(dis_result, aggregate):
    # dis_result = co_result
    pred = dis_result['decoded_power']
    gt = dis_result['actaul_power']
    error = []
    numerator = 0
    for app in gt.columns:
        numerator = sum(abs(pred[app].values - gt[app].values))
        denominator = aggregate * 1.0  # to make it float
        print (1 - 2*(numerator / denominator))
    #return (1 - (numerator / denominator))

def accuracy_metric_gemello(dis_result):
    '''This per appliance accuracy metric is used in Gamello. Paper mentions that it is based on works 1,7 mentioned in gamello paper'''
    ### this fails when there are 0 values in the denominator
    pred = dis_result['decoded_power']
    gt = dis_result['actaul_power']
    per_accu = {}
    for app in gt.columns:
        per_error = (abs(pred[app].values - gt[app].values)/ (gt[app] * 1.0)) * 100
        per_accu[app] = np.mean(per_error)
        #
    result = pd.DataFrame.from_dict(per_accu, orient='index')
    return result

def accuracy_metric_norm_error(dis_result):
    '''Metric taken from Nipuns NILMTK paper:Normalised error in assigned power'''
    pred = dis_result['decoded_power']
    gt = dis_result['actaul_power']
    error = {}
    for app in gt.columns:
        numerator = np.nansum(abs(pred[app].values - gt[app].values))
        denominator = np.nansum(gt[app]) * 1.0
        error[app] = np.divide(numerator,denominator)
    result = pd.DataFrame.from_dict(error, orient='index')
    return result


def sensitivity_localize_anomalous_appliance(fhmm_result, train_result, appliance_count, take_context,sigma):
    """ Required at testing time
    input: dissaggregated appliance data and the appliance statistics/models from training data
    input : appliance_count: this parameter decides if we  have one appliance or more than one. for one appliance this should be
    1 , and for rest any value will suffice: Basically using this parameter we call different functions
    output:find whether appliance is anomalous on day basis"""
    test_temp = deepcopy(fhmm_result)
    m = map(str, test_temp.index.strftime('%m'))  # month
    d = map(str, test_temp.index.strftime('%d'))  # days
    import operator
    ind = map(operator.add, m, d)  # create key using combination
    day_dat = test_temp.groupby(ind)
    result = []
    for key, value in day_dat:  # day level slicing
        daydat_temp = value
        #print 'stage1'
        if appliance_count == 1:  # of only one appliance, then appliance slicing level not required
            appliance_anomaly_result_version2(daydat_temp, train_result, take_context)
        else:
            # case when appliance level slicing required
            appliances = daydat_temp.columns
            #print 'stage2'
            for i in range(len(appliances)):  # appliance level slicing
                if any(daydat_temp[appliances[i]]):
                    # FIXME select proper function
                    #result.append(appliance_anomaly_result(daydat_temp[appliances[i]], train_result, appliances[i], take_context))
                    result.append(sensitivity_appliance_anomaly_result_test_func(daydat_temp[appliances[i]], train_result, appliances[i], take_context,sigma))
                    #print appliances[i]
                else:
                    print 'stage__continue'
                    continue
    final_result = pd.concat(result)
    return final_result

def sensitivity_appliance_anomaly_result_test_func(test_day, area_stat, device, take_context,sigma):  # area_stat stores training models results
    """ function called by localize_anomalous_appliance,used at testing time.
     It works at day level data for each appliance separately"""
    # print "start:"+device+":"+test_day.index.date[0].strftime('%d/%m/%Y')

    if take_context:
        test_res = cluster_appliance_testing_stage_with_time_context(test_day, device)
        area_stat = area_stat[device]
        df = pd.DataFrame()# for storing results
        air_status = 0
        refrigerator_status = 0
        if device == "air1":
            air_status = 1
        else:
            refrigerator_status = 1
        for key, context in area_stat.iteritems():
            test = test_res[key]  # corresponding context data from test day
            #FIXME  TUNABLE PARAMETERS ARE PRESENT HERE; Sensitivity function
            #for i in range(context.shape[0]):  # for no. of rows corresponding to no.of clusters/states
            states = test.shape[0]-1 #no. of states found during clustering in the concerned data
            if states == 0: # device remained off for full day
                print "state " + str(1) + " is not in " + device + " on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y') + " at " + key + " time"
                continue
            if ((test.loc[0].mean_area <= context.loc[0].mean_area - sigma * context.loc[0].sd_area) & (test.loc[1].mean_area <= context.loc[1].mean_area - sigma * context.loc[1].sd_area)):
                #print "frequent case"
                print device + " Frequent Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y') + " at " + key + " time"
                anom_type = "frequent"
                df = df.append({'Date': np.unique(test_day.index.date)[0].strftime(
                    '%Y-%m-%d'), 'air1': air_status, 'refrigerator1': refrigerator_status, 'context': key,
                    'Anom_type': anom_type, 'Magnitude': test.loc[1].mean_mag}, ignore_index=True)
            elif ((test.loc[1].mean_area >= context.loc[1].mean_area + sigma * context.loc[1].sd_area) & (test.loc[0].mean_duration > 2 * context.loc[0].mean_duration)):
                #"when person was out for long time and then suddenly he used ac is not an anomaly"
                print device + " Not Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y') + " at " + key + " time"
                continue
            elif (test.loc[1].mean_area >= context.loc[1].mean_area + sigma * context.loc[1].sd_area):
                #print "elongated case"
                print device + " Elongated Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y') + " at " + key + " time"
                anom_type = "elongated"
                df = df.append({'Date': np.unique(test_day.index.date)[0].strftime(
                    '%Y-%m-%d'), 'air1': air_status, 'refrigerator1': refrigerator_status, 'context': key,
                    'Anom_type': anom_type, 'Magnitude': test.loc[1].mean_mag}, ignore_index=True)

        return df
    else:
        test_res = cluster_appliance_testing_stage(test_day, device)
        test_res = test_res.sort_values(by='mean_mag', ascending=True)
        test_res = test_res.reset_index(drop=True)
        area_stat = area_stat[device]
        for i in range(area_stat.shape[0]):
            if (test_res.loc[i].mean_area <= area_stat.loc[i].mean_area - 1.5 * area_stat.loc[i].sd_area):
                print device + "Frequent Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y')
            elif (test_res.loc[i].mean_area >= area_stat.loc[i].mean_area + 1.5 * area_stat.loc[i].sd_area):
                print device + "Elongated Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y')


