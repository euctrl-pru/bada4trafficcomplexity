library(readr)
library(fs)
library(tibble)
library(dplyr)

# bd <- "G:/HQ/dgof-pru/Data/Application/Complexity_version_C/Data/Bada/3_15_201912/bada_files/"
# bf <- "A10___.PTF"
#
# ptf_file <- paste0(bd, bf)

read_bada_ptf <- function(ptf_file, bada_ver = "3.15-201912") {
  aircraft_id <- ptf_file %>%
    fs::path_file() %>%
    fs::path_ext_remove()

  # column names
  cn <- c(
    # "AT_ID",
    "FLIGHT_LEVEL",
    "CRUISE_TAS",
    "CRUISE_FUEL_LO",
    "CRUISE_FUEL_NO",
    "CRUISE_FUEL_HI",
    "CLIMB_TAS",
    "CLIMB_ROCD_LO",
    "CLIMB_ROCD_NO",
    "CLIMB_ROCD_HI",
    "CLIMB_FUEL_NO",
    "DESCENT_TAS",
    "DESCENT_ROCD_NO",
    "DESCENT_FUEL_NO"
  )

  # data format (in FORTRAN notation, from 'PTF FILE FORMAT' in BADA User Manual)
  # NOTE: remove the specification of decimal places, i.e. "F5.1" -> "F5"
  fmt <- c(
    # FL
    "I3",
    # CRUISE
    # -- TAS
    "4X", "I3", "2X",
    # -- fuel
    "1X1", "F5",
    "1X1", "F5",
    "1X1", "F5",
    # CLIMB
    # -- TAS
    "5X", "I3", "2X",
    # -- ROCD
    "1X", "I5",
    "1X", "I5",
    "1X", "I5",
    # -- fuel
    "3X", "F5",
    # DESCENT
    # -- TAS
    "5X", "I3",
    # -- ROCD
    "2X", "I5",
    # -- fuel
    "2X", "F5"
  )

  utils::read.fortran(
    ptf_file,
    skip = 16,
    # TRICK to filter horizontal line of '=' chars
    comment.char = "=",
    col.names = cn,
    format = fmt
  ) %>%
    tibble::as_tibble() %>%
    dplyr::filter(!is.na(FLIGHT_LEVEL)) %>%
    tibble::add_column("AT_ID" = aircraft_id, .before = 1) %>%
    tibble::add_column("BADA_VERSION" = bada_ver)
}

read_bada_syn <- function(syn_file, bada_ver = "3.15-201912") {

  # column names
  cn <- c(
    "AIRCRAFT_CODE",
    "MANUFACTURER",
    "MODEL",
    "AT_ID",
    "OLD_AIRCRAFT_CODE",
    "BADA_VERSION"
  )

  # data format (in FORTRAN notation, from 'SYNONYM FILE FORMAT' in BADA User Manual)
  cols <- fwf_cols(
    "SUPPORT_TYPE"  = c(4, 5),
    "AIRCRAFT_CODE" = c(6, 11),
    "MANUFACTURER"  = c(13, 31),
    "MODEL"         = c(33, 56),
    "FILE"          = c(58, 64),
    "ICAO"          = c(66, 67)
  )

  readr::read_lines(syn_file, skip_empty_rows = TRUE, locale = locale(encoding = "latin1")) %>%
    stringr::str_subset(pattern = "^CD") %>%
    readr::read_fwf(cols) %>%
    tibble::add_column("BADA_VERSION" = bada_ver)
}


bv <- "3.15-201912"
bd <- "G:/HQ/dgof-pru/Data/Application/Complexity_version_C/Data/Bada/3_15_201912/bada_files/"

#-------- PTF files
ptf_files <- fs::dir_ls(bd, glob = "*.PTF")
rbpft <- purrr::partial(read_bada_ptf, bada_ver = bv)
df <- purrr::map_dfr(ptf_files, rbpft)

# this is for loading to Oracle
df %>%
  arrange(AT_ID) %>%
  readr::write_csv("bada_ptf.csv", na = "")

# this is for Traffic Complexity BADA file
df %>%
  arrange(AT_ID) %>%
  filter(!is.na(CRUISE_TAS)) %>%
  select(AT_ID, FLIGHT_LEVEL, CRUISE_TAS, CLIMB_TAS, DESCENT_TAS) %>%
  readr::write_delim("TB_OGIS_BADA_AIRCRAFT_PERF.txt", delim = ";", na = "", col_names = FALSE)

#-------- SYNONYM.NEW
syn_file <- fs::path_join(c(bd, "SYNONYM.NEW"))
df <- read_bada_syn(syn_file, bada_ver = bv)

# this is for loading to Oracle
df_oracle <- df %>%
  arrange(AIRCRAFT_CODE) %>%
  select(AIRCRAFT_CODE, MANUFACTURER, MODEL, FILE, BADA_VERSION) %>%
  rename(AT_ID = FILE) %>%
  tibble::add_column(OLD_AIRCRAFT_CODE = NA_character_, .before = "BADA_VERSION")
# save to local file
df_oracle %>%
  readr::write_csv("bada_syn.csv", na = "")

# save for traffic complexity
df_oracle %>%
  select(AIRCRAFT_CODE, AT_ID) %>%
  readr::write_delim("TB_OGIS_BADA_AIRCRAFT_TYPE.txt", delim = ";", na = "", col_names = FALSE)
