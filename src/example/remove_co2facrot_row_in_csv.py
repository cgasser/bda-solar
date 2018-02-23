#!/usr/bin/env python3
### Remove new added 'co2factor' in csv
import pandas as pd
import glob
from hdfs import InsecureClient
import csv

path = '/home/bda/data'
path_temp = '/home/bda/temp'
client = InsecureClient('http://nh-01.ip-plus.net:50070', user='hdfs')
allFiles = sorted(glob.glob(path + "/*.csv"))
for file_ in allFiles:
    df = pd.read_csv(file_, delimiter='\t')
    print(df)
    if 'co2factor' in df.columns:
        del df['co2factor']
        print("we have a co2factor")
        print(df)
        filename = file_.replace(path, '')
        df.to_csv(path_temp + filename, sep='\t')
        #with client.write(file_, encoding='utf-8') as writer:
        #    w = csv.DictWriter(writer, df.keys(), dialect=csv.excel_tab)
        #    w.writeheader()
        #    w.writerow(df)