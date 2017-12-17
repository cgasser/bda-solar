#!/usr/bin/env python3

import os, json
from pandas.io.json import json_normalize
import pandas as pd


def read_multiple_json(data_frame, path_to_json):
    # this finds our json files
    json_files = [pos_json for pos_json in os.listdir(path_to_json) if pos_json.endswith('.json')]

    # here I define my pandas Dataframe with the columns I want to get from the json
    frames = []
    # we need both the json and an index number so use enumerate()
    for index, js in enumerate(json_files):
        with open(os.path.join(path_to_json, js)) as json_file:
            json_data = json.load(json_file)
        _data = pd.io.json.json_normalize(json_data)
        #data_frame.loc[index] = _data
        frames.append(_data)

    return data_frame.append(frames)


def read_single_json(json_file):
    with open(json_file) as data_file:
        _data = json.load(data_file)
    _data = pd.io.json.json_normalize(_data)
    return _data


if __name__ == "__main__":
    #create Dataframe
    data = read_single_json('/home/claude/repo/bda-solar/data/data_timestamp/pfadibaar_solarlog_1509887998.json')
    df = pd.DataFrame.from_records(data)
    #Load Dataframe
    dataframe = read_multiple_json(df, '/home/claude/repo/bda-solar/data/data_timestamp')
    print(dataframe.describe())
    #df['cur_yield_watt '].hist(by=df['timestamp'])
    dataframe.cur_yield_watt.hist()
    dataframe.to_csv('/home/claude/repo/bda-solar/data/temp/converted_solarlog.csv')