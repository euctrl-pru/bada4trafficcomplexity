#! /bin/awk -f

# check that BADA aircraft performance files have the number of fields
# expected in convertPTF.awk
#
# Usage
#
# $ awk -f sanity_check_PTF.awk bada/*.PTF

# capture aircraft type
FNR == 3 { AC_TYPE = $2; error = 0 }

# check that there are either 12, 3, 16 or 1 fields
# 3: there is no valur for any of the sections
FNR >= 17 && NF != 12 && NF != 3 && NF != 16 && NF != 1 { error = 1; print NF, AC_TYPE, $0}

# 1: the last horizontal line ======
# FNR >= 17 && NF == 1 { print NF, AC_TYPE, $0}

# 3: the empty lines between flight levels
# FNR >= 17 && NF == 3 { print NF, AC_TYPE, $0}

# 12: the FL where CRUISE data is not present
# FNR >= 17 && NF == 12 { print NF, AC_TYPE, $0}

# 16: the FL where CRUISE data is not present
#FNR >= 17 && NF == 16 { print NF, AC_TYPE, $0}

END {
    if (error) {
        print "\nThere is something fishy in the PTF files!" > "/dev/stderr"
        exit 1
    }
}
