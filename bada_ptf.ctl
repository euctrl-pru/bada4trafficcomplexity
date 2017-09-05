load data
infile 'bada_ptf.csv' "str '\n'"
append
into table OGIS_BADA_AIRCRAFT_PERF_TEST
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( AT_ID CHAR(4000),
             FLIGHT_LEVEL CHAR(4000),
             CRUISE_TAS CHAR(4000),
             CRUISE_FUEL_LO CHAR(4000),
             CRUISE_FUEL_NO CHAR(4000),
             CRUISE_FUEL_HI CHAR(4000),
             CLIMB_TAS CHAR(4000),
             CLIMB_ROCD_LO CHAR(4000),
             CLIMB_ROCD_NO CHAR(4000),
             CLIMB_ROCD_HI CHAR(4000),
             CLIMB_FUEL_NO CHAR(4000),
             DESCENT_TAS CHAR(4000),
             DESCENT_ROCD_NO CHAR(4000),
             DESCENT_FUEL_NO CHAR(4000),
             BADA_VERSION CHAR(4000)
           )
