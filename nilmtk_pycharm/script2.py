


def appliance_anomaly_result_test_func(test_day, area_stat, device, take_context):  # area_stat stores training models results
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
            #FIXME  TUNABLE PARAMETERS ARE PRESENT HERE
            #for i in range(context.shape[0]):  # for no. of rows corresponding to no.of clusters/states
            states = test.shape[0]-1 #no. of states found during clustering in the concerned data
            if states == 0: # device remained off for full day
                print "state " + str(1) + " is not in " + device + " on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y') + " at " + key + " time"
                continue
            if ((test.loc[0].mean_area <= context.loc[0].mean_area - 1.0 * context.loc[0].sd_area) & (test.loc[1].mean_area <= context.loc[1].mean_area - 1.0 * context.loc[1].sd_area)):
                #print "frequent case"
                print device + " Frequent Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y') + " at " + key + " time"
                anom_type = "frequent"
                df = df.append({'Date': np.unique(test_day.index.date)[0].strftime(
                    '%Y-%m-%d'), 'air1': air_status, 'refrigerator1': refrigerator_status, 'context': key,
                    'Anom_type': anom_type, 'Magnitude': test.loc[1].mean_mag}, ignore_index=True)
            elif ((test.loc[1].mean_area >= context.loc[1].mean_area + 1.0 * context.loc[1].sd_area) & (test.loc[0].mean_duration > 2 * context.loc[1].mean_duration)):
                #"when person was out for long time and then suddenly he used ac is not an anomaly"
                print device + " Not Anomaly on " + np.unique(test_day.index.date)[0].strftime('%d/%m/%Y') + " at " + key + " time"
                continue
                #anom_type = "elongated"
                #df = df.append({'Date': np.unique(test_day.index.date)[0].strftime(
                    #'%Y-%m-%d'), 'air1': air_status, 'refrigerator1': refrigerator_status, 'context': key,
                    #'Anom_type': anom_type, 'Magnitude': test.loc[1].mean_mag}, ignore_index=True)
            elif (test.loc[1].mean_area >= context.loc[1].mean_area + 1.0 * context.loc[1].sd_area):
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

