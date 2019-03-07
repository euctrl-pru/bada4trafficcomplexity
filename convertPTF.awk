#! /bin/awk -f

# convert BADA aircraft performance data in CSV format suitable to be imported
# in ORACLE schema for Traffic Complexity Score
#
# Output a CSV formatted dataset on stdout.
# Output erroneus data on stderr.
# Exit statu is 0 if all ok, 1 otherwise.
# Usage
#
# $ awk -f convertPTF.awk -v ver=3.13.1 bada/*.PTF > bada_ptf.csv
# $ echo $?
# 0 # all ok!!!


# insert the columns headings
BEGIN {
    if (length(ver) == 0) {
        print "BADA version not specified, please invoke with '-v BADA_VER=x.y.x'" > "/dev/stderr"
        exit 1
    }

	print "AT_ID,FLIGHT_LEVEL,CRUISE_TAS,CRUISE_FUEL_LO,CRUISE_FUEL_NO,CRUISE_FUEL_HI,CLIMB_TAS,CLIMB_ROCD_LO,CLIMB_ROCD_NO,CLIMB_ROCD_HI,CLIMB_FUEL_NO,DESCENT_TAS,DESCENT_ROCD_NO,DESCENT_FUEL_NO,BADA_VERSION"
}

# extract the aircaft type
FNR == 3 { AC_TYPE = $2 }

# spit the values from the aircraft performance table
# Typically for lower flight levels cruise values do not exist, hence only 12 fields are available
FNR >= 17 && NF == 12 {
    printf "%s,%i,,,,,%i,%i,%i,%i,%.1f,%i,%i,%.1f,%s\n", AC_TYPE,$1,$4,$5,$6,$7,$8,$10,$11,$12,ver
}

FNR >= 17 && NF == 16 {
    printf "%s,%i,%i,%.1f,%.1f,%.1f,%i,%i,%i,%i,%.1f,%i,%i,%.1f,%s\n", AC_TYPE,$1,$3,$4,$5,$6,$8,$9,$10,$11,$12,$14,$15,$16,ver
}


# if there is a fishy line spit it in stderr
FNR >= 17 && NF != 12 && NF != 3 && NF != 16 && NF != 1 { error = 1; print NF, AC_TYPE, $0  > "/dev/stderr"}

END {
    if (error) {
        print "\nThere is something fishy in the PTF files!" > "/dev/stderr"
        exit 1
    }
}
