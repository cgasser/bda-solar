#!/usr/bin/env python3
# Conversion script to for given daily csv from Birchli to one csv with datetime

import os, json,csv
from pandas.io.json import json_normalize
import pandas as pd
import glob
import datetime as datetime



if __name__ == "__main__":
    path = '/home/claude/repo/bda-solar/data/birchli/SBEAM/'
    allFiles = sorted(glob.glob(path + "/*.CSV"))
    frame = pd.DataFrame()
    list_ = []
    for file_ in allFiles:
        df = pd.read_csv(file_, index_col=None, header=6, sep=';')
        df = df.drop(144)
        df = df.drop(145)
        df['timestamp'] = file_.replace(path,'').replace('.CSV','')
        df['timestamp'] = df['timestamp'] + ' ' + df['HH:mm']
        #print(df['datetime'])
        df['timestamp'] = pd.to_datetime(df['timestamp'],format='%y-%m-%d %H:%M')
        if ('kW.1' in df.columns.values):
            df['yield_tot'] = df['kW'] + df['kW.1']
        else:
            df['yield_tot'] = df['kW']
        df.drop('HH:mm', axis=1, inplace=True)
        list_.append(df)
        df.rename(columns={'kW': 'yield_1', 'kW.1': 'yield_2'}, inplace=True)

    frame = pd.concat(list_,ignore_index=True)

    frame.to_csv('/home/claude/repo/bda-solar/data/birchli/birchli_20180112.csv',sep='\t')