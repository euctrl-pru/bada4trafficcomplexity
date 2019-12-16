# BADA for Traffic Complexity

Traffic Complexity Score uses BADA coefficients for aircraft performance.

The scripts in this directory are used to extract the aircraft performance
parameters in a CSV file that can then be imported in the relevant ORACLE schema.

Please note that all scripts are version controlled under git and
[hosted on Github][repo] at the following URL:

https://github.com/euctrl-pru/bada4trafficcomplexity

Should you need any changes, please submit a pull request.

**NOTE**: there is an R script that can help in generating all the `.csv` and
`.txt` files. (upload to Oracle can then be done trivially as detailed below
or via R directly.)


## Prerequisites and Setup

You need to set the following environment variable for the relevant DB connection:

* `PRU_OGIS_USR`: the username for the Oracle GIS database
* `PRU_OGIS_PWD`: the password for the Oracle GIS database
* `PRU_OGIS_DBNAME`: the databse name for the Oracle GIS database

The scripts also rely on running versions of `awk`, `unzip`,
a shell (`bash` or MS Windows `cmd`) and Oracle SQL Loader if you decide
to use it to import CSV files.

You can either run a Unix script `.sh` or a MS Windows batch script `.bat`.

## Extract BADA dataset

Extract the BADA main and update zip files in a folder named `bada` (**Accept to overwrite the `SYNONYM.NEW`**)

```shell
$ unzip -d bada /g/HQ/dgof-pru/Data/DataProcessing/Bada/3.14/bada_314_96b6f733f5b65f32a5e7.zip
$ unzip -d bada /g/HQ/dgof-pru/Data/DataProcessing/Bada/3.14/bada_314_update_201810_c1d6e14cc247c8f5b6f6.zip
```


The `bada` folder should now contains a set of files like:

```shell
$ ls -l bada/
$ ls -l bada
total 10045
-rw-r--r-- 1 spi 1049089    2523 Mar  7 08:26 A10___.APF
-rw-r--r-- 1 spi 1049089    4392 Mar  7 08:26 A10___.OPF
-rw-r--r-- 1 spi 1049089   15279 Mar  7 08:26 A10___.PTD
-rw-r--r-- 1 spi 1049089    5654 Mar  7 08:26 A10___.PTF
-rw-r--r-- 1 spi 1049089    2523 Mar  7 08:26 A124__.APF
-rw-r--r-- 1 spi 1049089    4392 Mar  7 08:26 A124__.OPF
-...
...
-rw-r--r-- 1 spi 1049089    8245 Mar  7 08:29 U2____.PTF
-rw-r--r-- 1 spi 1049089    2523 Mar  7 08:29 YK40__.APF
-rw-r--r-- 1 spi 1049089    4392 Mar  7 08:29 YK40__.OPF
-rw-r--r-- 1 spi 1049089   10626 Mar  7 08:29 YK40__.PTD
-rw-r--r-- 1 spi 1049089    4196 Mar  7 08:30 YK40__.PTF
-rw-r--r-- 1 spi 1049089    2523 Mar  7 08:30 YK42__.APF
-rw-r--r-- 1 spi 1049089    4392 Mar  7 08:30 YK42__.OPF
-rw-r--r-- 1 spi 1049089   12177 Mar  7 08:30 YK42__.PTD
-rw-r--r-- 1 spi 1049089    4682 Mar  7 08:30 YK42__.PTF
```

## Convert to Unix line-ending

The `awk` scripts expect Unix line-ending, so convert all BADA files:

```shell
$ dos2unix bada/*.PTF
```


## Sanity check

In order to make sure that there is no spurious data file or
that the file format has not changed, you need to run the
`sanity_check_PTF.awk` script

```shell
$ ./sanity_check_PTF.awk bada/*.PTF
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
$ ./sanity_check_PTF.awk bada/*.PTF
$ echo $?
0
```

## Prepare the dataset for ORACLE

The following command will extract the relevant aircraft performance
parameters in CSV format:

```shell
$ awk -f convertPTF.awk -v ver=3.14-201810 bada/*.PTF > bada_ptf.csv
$ echo $?
0
$ awk -f convertSYN.awk -v ver=3.14-201810 bada/SYNONYM.NEW > bada_syn.csv
$ echo $?
0
```

The outcome is similar to the following:

```shell
$ head bada_ptf.csv
AC_TYPE,FL,CRUISE_TAS,CRUISE_FUEL_LO,CRUISE_FUEL_NO,CRUISE_FUEL_HI,CLIMB_TAS,CLIMB_ROCD_LO,CLIMB_ROCD_NO,CLIMB_ROCD_HI,CLIMB_FUEL_NO,DESCENT_TAS,DESCENT_ROCD_NO,DESCENT_FUEL_NO,BADA_VERSION
A10___,0,,,,,155,3164,2637,2271,38.7,150,799,6.4,3.14-201810
A10___,5,,,,,156,3139,2611,2244,38.5,151,812,6.4,3.14-201810
A10___,10,,,,,157,3114,2585,2217,38.2,157,1178,3.8,3.14-201810
A10___,15,,,,,164,3198,2641,2256,38.7,169,1257,3.8,3.14-201810
A10___,20,,,,,165,3171,2613,2227,38.5,180,1687,3.8,3.14-201810
A10___,30,224,17.3,19.2,21.1,188,3474,2810,2362,41.0,183,1712,3.8,3.14-201810
A10___,40,228,17.5,19.3,21.3,212,3716,2885,2335,43.4,185,1737,3.8,3.14-201810
A10___,60,234,17.8,19.7,21.7,218,3576,2732,2192,42.3,191,1787,3.8,3.14-201810
A10___,80,241,18.2,20.1,22.1,225,3394,2572,2044,41.2,197,1840,3.8,3.14-201810
```

## Import to ORACLE

You can use TOAD or SQL Developer to load the CSV files in the relevant tables.

Otherwise import scripts and support files for SQL Loader can be generated via
SQL Developer as described in [this post][sqlldr].

The files `bada_ptf.sh` (for Windows `bada_ptf.bat`) and `bada_ptf.ctl` are
an example for the `PTF` values.

If you want to reuse them, **Please change the relevant filepath in order to
accomodate for the actual location of the CSV and log files and/or ORACLE table.**

For example `bada_ptf.ctl` and `bada_syn.ctl` need to specify `OGIS_BADA_AIRCRAFT_PERF_3_14` and `OGIS_BADA_AIRCRAFT_TYPE_3_14` respectively as table names holding performance and aircraft type values.

In order to import the `bada_ptf.csv`  and `bada_syn.csv` it then suffice to execute

```shell
$ ./bada_ptf.sh
$ ./bada_syn.sh
```

Please check the *log* files for any errors.

## Epilogue

You can generate a PDF file from the `README.md` using `pandoc` (with A4 paper size
and reduced 2 cm margins):

```shell
$ pandoc -V papersize:a4 -V geometry:margin=2cm -o README.pdf README.md
```

[repo]: <https://github.com/euctrl-pru/bada4trafficcomplexity> "BADA scripts repo"
[sqlldr]: <http://www.thatjeffsmith.com/archive/2012/08/using-oracle-sql-developer-to-setup-sqlloader-runs/> "Generate SQL Loader script"
