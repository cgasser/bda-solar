#!/usr/bin/env python3
## Create inventory_solar file for HDFS table
## In case of changing the schema also update the hive table!
import pandas as pd

pv_sites = [{'id':  '51769',    'plantname':'Pfadiheim Baar',                   'zip': 'CH - 6340 Baar',                'neigung':'14°',    'ausrichtung':'22°', 'anlagenleistung':'12.72' },
            {'id':  '26678',    'plantname':'Winsun AG, Steg',                  'zip': 'CH - 3940 Steg',                'neigung':'6°',     'ausrichtung':'-13°', 'anlagenleistung':'60' },
            {'id':  '54349',    'plantname':'Meyer Rolf, Baar',                 'zip': 'CH - 6340 Baar',                'neigung':'5°',     'ausrichtung':'-43°', 'anlagenleistung':'12' },
            {'id':  '48542',    'plantname':'Himmelrichstrasse 1ab, Baar',      'zip': 'CH - 6340 Baar',                'neigung':'13°',    'ausrichtung':'-55°', 'anlagenleistung':'18.6' },
            {'id':  '55610',    'plantname':'Betschart René, Steinhausen',       'zip': 'CH - 6312 Steinhausen',        'neigung':'5°',     'ausrichtung':'-37°', 'anlagenleistung':'12' },
            {'id':  '58209',    'plantname': 'Maechler Paul, Allenwinden',      'zip': 'CH - 6319 Allenwinden',         'neigung':'30°',    'ausrichtung':'-33°', 'anlagenleistung':'10' },
            {'id':  '52738',    'plantname': 'Haller Roman, Rifferswil',        'zip': 'CH - 8911 Rifferswil',          'neigung': '39°' ,  'ausrichtung':'-70°', 'anlagenleistung': '23.49'},
            {'id':  '55610',    'plantname':'Loosmann Johannes, Hausen am Albis', 'zip': 'CH - 8915 Hausen am Albis', 'neigung':'14°',      'ausrichtung':'-47°°', 'anlagenleistung':'5.5' }]

dataframe = pd.DataFrame(data=pv_sites)
dataframe.to_csv(path_or_buf='/home/claude/repo/bda-solar/data/temp/inventory_solar.csv',sep='\t', encoding='utf-8')
