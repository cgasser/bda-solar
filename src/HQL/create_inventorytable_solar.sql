--run directly in HIVE editor over hue
CREATE EXTERNAL TABLE `default`.`inventory_solar`
(
  `index` bigint ,
  `anlagenleistung` double ,
  `ausrichtung` string ,
  `id` bigint ,
  `neigung` string ,
  `plantname` string ,
  `zip` string ) COMMENT "Loaded Winsun AG Plants"
ROW FORMAT   DELIMITED
    FIELDS TERMINATED BY '\t'
  STORED AS TextFile LOCATION '/data/inventory'
TBLPROPERTIES("skip.header.line.count" = "1")