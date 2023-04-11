cwlVersion: v1.2
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  MultipleInputFeatureRequirement: {}

inputs:
  start_year:
    label: Year for starting date
    type: int
  start_month:
    label: Month for starting date
    type: int
  start_day:
    label: Day for starting date
    type: int
  end_year:
    label: Year for end date
    type: int
  end_month:
    label: Month for end date
    type: int
  end_day:
    label: Day for end date
    type: int
  north_latitude:
    label: Latitude for top of domain
    type: int
  south_latitude:
    label: Latitude for bottom of domain
    type: int
  west_longitude:
    label: Longitude for left-edge of domain
    type: int
  east_longitude:
    label: Longitude for right-edge of domain
    type: int
  cdskey:
    label: API key for CDS service
    type: File
    
outputs:
  gribfiles_atm:
    label: ERA5 atmospheric data
    type:
      type: array
      items: File
    outputSource: step1_era5/grib_files_atm
  gribfiles_sfc:
    label: ERA5 surface data
    type:
      type: array
      items: File
    outputSource: step1_era5/grib_files_sfc

steps:
  step1_era5:
    run: atmos:cwl/Met_Downloads/era5_download.cwl
    in:
      start_year: start_year
      start_month: start_month
      start_day: start_day
      end_year: end_year
      end_month: end_month
      end_day: end_day
      north_latitude: north_latitude
      south_latitude: south_latitude
      west_longitude: west_longitude
      east_longitude: east_longitude
      cdskey: cdskey
    out: [grib_files_atm, grib_files_sfc]

$namespaces:
  atmos: https://raw.githubusercontent.com/UoMResearchIT/atmos-tools-library/main/

