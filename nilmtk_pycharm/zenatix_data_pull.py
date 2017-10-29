
from smap.archiver.client import SmapClient
from smap.contrib import dtutil
import numpy as np
import pandas as pd
import datetime
import subprocess

#Link to download the data
c = SmapClient("http://iiitdarchiver.zenatix.com:9105")

#Range of dates to which you want to download the data

start = dtutil.dt2ts(dtutil.strptime_tz("01-10-2017", "%d-%m-%Y"))
end = dtutil.dt2ts(dtutil.strptime_tz("01-10-2017", "%d-%m-%Y"))

# hard-code the UUIDs we want to download
oat = [
  "eec41258-f057-591e-9759-8cfdeb67b9af"
]

# Function to perform the download of the data
data = c.data_uuid(oat, start, end)

t= np.array(data)
df = pd.DataFrame(t)

# creating files after downloading
for i, j in enumerate(t):
    name= str(i) + '.csv'
    with open(name, 'w') as f:
        for time, val in j:
            f.write(str(datetime.datetime.fromtimestamp(time/1000.0)) + ' , ' + str(float(val)) + '\n')
   #print "%d sensor file written" %(i)