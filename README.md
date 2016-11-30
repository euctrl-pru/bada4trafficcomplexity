# BADA for Traffic Complexity

Traffic Complexity Score uses BADA coefficients for aircraft performance.

The scripts in this directory are used to extract the aircraft performance
parameters in a CSV file that can then be imported in the relevant ORACLE schema.

## Extract BADA dataset

Extract the BADA zip in a folder, i.e. `bada_3131`

This folder should now contains a set of files like:

```shell
$ ls -l bada_3131
total 6580
-rw-r--r-- 1 spi 1049089  2547 May 13  2013 A124__.APF
-rw-r--r-- 1 spi 1049089  4453 May 13  2013 A124__.OPF
-rw-r--r-- 1 spi 1049089 14376 May 22  2013 A124__.PTD
-rw-r--r-- 1 spi 1049089  5401 May 22  2013 A124__.PTF
-rw-r--r-- 1 spi 1049089  2547 May 15  2013 A140__.APF
-rw-r--r-- 1 spi 1049089  4453 May 15  2013 A140__.OPF
-rw-r--r-- 1 spi 1049089 10208 May 22  2013 A140__.PTD
-rw-r--r-- 1 spi 1049089  4087 May 22  2013 A140__.PTF
...
...
-rw-r--r-- 1 spi 1049089  2547 May  7  2013 YK40__.APF
-rw-r--r-- 1 spi 1049089  4453 Aug 22  2014 YK40__.OPF
-rw-r--r-- 1 spi 1049089 10729 Aug 25  2014 YK40__.PTD
-rw-r--r-- 1 spi 1049089  4251 Aug 25  2014 YK40__.PTF
-rw-r--r-- 1 spi 1049089  2547 May  7  2013 YK42__.APF
-rw-r--r-- 1 spi 1049089  4453 May  7  2013 YK42__.OPF
-rw-r--r-- 1 spi 1049089 12292 May 22  2013 YK42__.PTD
-rw-r--r-- 1 spi 1049089  4743 May 22  2013 YK42__.PTF
```

## Sanity check

In order to make sure that there is no spurious data file or
that the file format has not changed, you need to run the
`sanity_check_PTF.awk` script

```shell
$ ./sanity_check_PTF.awk bada_3131/*.PTF
1 TBM8__ ==================================================
1 YK40__ ==================================================
1 YK42__ ==================================================

There is something fishy in the PTF files!
$ echo $?
1
```

The erroneus rows will be printed on `stderr` and exit status would then be `1`.
Otherwise if all is ok exit status will be `0`:

```shell
$ ./sanity_check_PTF.awk bada_3131/*.PTF
$ echo $?
0
```

## Prepare the dataset for ORACLE

The following command will extract the relevant aircraft performance
parameters in CSV format:

```shell
$ ./convertPTF.awk bada_3131/*.PTF > bada_3131.csv
$ echo $?
0
```

The outcome is similar to the following:

```shell
$ head bada_3131.csv
AC_TYPE,FL,CRUISE_TAS,CRUISE_FUEL_LO,CRUISE_FUEL_NO,CRUISE_FUEL_HI,CLIMB_TAS,CLIMB_ROCD_LO,CLIMB_ROCD_NO,CLIMB_ROCD_HI,CLIMB_FUEL_NO,DESCENT_TAS,DESCENT_ROCD_NO,DESCENT_FUEL_NO
A124__,0,,,,,171,2204,1385,975,476.2,156,869,116.1
A124__,5,,,,,173,2202,1380,968,473.6,157,878,115.5
A124__,10,,,,,174,2201,1375,961,470.9,163,861,114.6
A124__,15,,,,,180,2304,1440,1012,467.2,175,829,113.4
A124__,20,,,,,182,2301,1434,1004,464.5,207,1261,110.2
A124__,30,230,143.3,197.3,246.7,205,2666,1661,1183,454.6,230,1375,108.6
A124__,40,233,143.0,197.0,246.4,240,3067,1884,1343,442.4,233,1397,106.9
A124__,60,272,160.7,201.9,239.6,272,3319,1925,1313,425.6,272,1841,103.6
A124__,80,280,159.8,200.9,238.6,280,3259,1872,1259,413.6,280,1890,100.3
...
```

## Import to ORACLE

An import script for SQL Loader can be generated via SQL Developer as described
in [this post][sqlldr].

**Please change the relevant filepath in order to accomodate for the actual
location of the CSV and log files and/or ORACLE table.**

In order to run the `bada_3131.csv` it then suffice to execute

```shell
$ ./bada_3131.sh
```


[sqlldr]: <http://www.thatjeffsmith.com/archive/2012/08/using-oracle-sql-developer-to-setup-sqlloader-runs/> "Generate SQL Loader script"
