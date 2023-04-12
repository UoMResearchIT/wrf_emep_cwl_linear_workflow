cwlVersion: v1.2
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  MultipleInputFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:
# ERA5 data download settings
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
  https_proxy:
    label: HTTPS proxy information, if needed
    type: string?

# Geogrid settings:
  geodir:
    label: Geographic inputs for geogrid
    type: Directory
  namelist_geogrid:
    label: Geogrid namelist
    type: File
  geotable:
    label: Geogrid data table
    type: File

# WPS settings:
  namelist_ungrib_atm:
    label: Configuration File
    type: File
  vtable_atm:
    label: grib variable table
    type: File
  outname_atm: string
  namelist_ungrib_sfc:
    label: Configuration File
    type: File
  vtable_sfc:
    label: grib variable table
    type: File
  outname_sfc: string
  namelist_metgrid:
    label: metgrid configuration
    type: File
  generate_metdir: boolean

# WRF settings:
  namelist_real:
    label: Real preprocessor Configuration File
    type: File
  namelist_wrf:
    label: WRF Configuration File
    type: File
  realcores: int
  wrfcores: int
  generate_rundir: boolean
    
# EMEP settings:
  namelist_emep:
    label: EMEP configuration file
    type: File
  inputdir_emep:
    label: EMEP Input Files
    type: Directory
  runlabel_emep:
    label: EMEP run label, for output files, should match 'runlabel1' in namelist
    type: string
  metdir_name:
    label: Directory name for WRF input Files, should match 'meteo' base-directory in namelist
    type: string
  emepcores: int


outputs:
  wrfout:
    label: output files
    type:
      type: array
      items: File
    outputSource: step4_wrf_workflow/wrfout
  emepout:
    label: output files
    type:
      type: array
      items: File
    outputSource: step5_emep_workflow/emepout


steps:
  step1_era5_workflow:
    run: workflows/era5_workflow.cwl
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
      https_proxy: https_proxy      
    out: [gribfiles_atm, gribfiles_sfc]

  step2_geogrid_workflow:
    run: workflows/geogrid_workflow.cwl
    in:
      geodir: geodir
      namelist: namelist_geogrid
      geotable: geotable
    out: [geofiles]
    
  step3_wps_workflow:
    run: workflows/wps_workflow.cwl
    in:
      namelist_ungrib_atm: namelist_ungrib_atm
      vtable_atm: vtable_atm
      grib_files_atm: step1_era5_workflow/gribfiles_atm
      outname_atm: outname_atm
      namelist_ungrib_sfc: namelist_ungrib_sfc
      vtable_sfc: vtable_sfc
      grib_files_sfc: step1_era5_workflow/gribfiles_sfc
      outname_sfc: outname_sfc
      namelist_metgrid: namelist_metgrid
      geo_files: step2_geogrid_workflow/geofiles
      generate_metdir: generate_metdir
    out: [metfiles]

  step4_wrf_workflow:
    run: workflows/wrf_workflow.cwl
    in:
      namelist_real: namelist_real
      namelist_wrf: namelist_wrf
      metfiles: step3_wps_workflow/metfiles
      realcores: realcores
      wrfcores: wrfcores
      generate_rundir: generate_rundir
    out: [wrfout]
    
  step5_emep_workflow:
    run: workflows/emep_workflow.cwl
    in:
      namelist_emep: namelist_emep
      metfiles_emep: step4_wrf_workflow/wrfout
      metdir_name: metdir_name
      inputdir_emep: inputdir_emep
      runlabel_emep: runlabel_emep
      emepcores: emepcores
    out: [emepout]
    

