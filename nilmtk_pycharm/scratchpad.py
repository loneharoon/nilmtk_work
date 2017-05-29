

def localize_anomalous_appliance(fhmm_result, train_result, appliance_count, take_context):
    """ Required at testing time
    input: dissgrated appliance data and the applaince statistics/models from training data
    input : appliance_count: this parameter decides if we  have one applinace or more than one. for one appliance this should be
    1 , and for rest any value will suffice: Basically using this parameter we call different functions
    output:find whether applaince is anomalous on day basis"""
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
                 result.append(appliance_anomaly_result(daydat_temp[appliances[i]], train_result, appliances[i], take_context))
                    #print appliances[i]
                else:
                    print 'stage__continue'
                    continue
    final_result = pd.concat(result)
    return final_result



