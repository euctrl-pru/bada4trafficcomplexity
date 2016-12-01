load data 
infile 'bada_syn_3131.csv' "str '\n'"
append
into table OGIS_BADA_AIRCRAFT_TYPE_TEST
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( AIRCRAFT_CODE CHAR(4000),
             MANUFACTURER CHAR(4000),
             MODEL CHAR(4000),
             AT_ID CHAR(4000),
             OLD_AIRCRAFT_CODE CHAR(4000),
             BADA_VERSION CHAR(4000)
           )
