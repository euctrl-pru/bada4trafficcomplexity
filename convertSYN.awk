#! /bin/awk -f

# convert BADA aircraft synonyms data in CSV format suitable to be imported
# in ORACLE schema for Traffic Complexity Score
#
# Output a CSV formatted dataset on stdout.
# Output erroneus data on stderr.
# Exit statu is 0 if all ok, 1 otherwise.
# Usage
#
# $ awk -f convertSYN.awk -v ver=3.13.1 bada/SYNONYM.NEW > bada_syn.csv
# $ echo $?
# 0 # all ok!!!


# insert the columns headings
BEGIN {
    if (length(ver) == 0) {
        print "BADA version not specified, please invoke with '-v BADA_VER=x.y.x'" > "/dev/stderr"
        exit 1
    }

    FIELDWIDTHS = "5 7 19 26 8 1"
    print "AIRCRAFT_CODE,MANUFACTURER,MODEL,AT_ID,OLD_AIRCRAFT_CODE,BADA_VERSION"
}

# spit the values from the aircraft synonym table
/CD/ {
    for (i = 1; i <= NF; i++) {
        sub(/ +$/, "", $i)
        sub(/^ +/, "", $i)
    }

#    print ">" $2 "<,>" $3 "<,>" $4 "<,>" $5 "<"
    print $2 "," $3 "," $4 "," $5 ",," ver
}

END {
    if (error) {
        print "\nThere is something fishy in the PTF files!" > "/dev/stderr"
        exit 1
    }
}
