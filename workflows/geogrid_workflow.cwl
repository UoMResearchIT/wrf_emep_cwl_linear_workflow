cwlVersion: v1.2
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  MultipleInputFeatureRequirement: {}

inputs:
  geodir:
    label: Geographic inputs for geogrid
    type: Directory
  namelist:
    label: Geogrid namelist
    type: File
  geotable:
    label: Geogrid data table
    type: File
    
outputs:
  logfiles:
    label: Geogrid logs
    type:
      type: array
      items: File
    outputSource: step1_geogrid/logfiles
  geofiles:
    label: Geogrid output files
    type:
      type: array
      items: File
    outputSource: step1_geogrid/geofiles

steps:
  step1_geogrid:
    run: atmos:cwl/WPS/geogrid.cwl
    in:
      geodir: geodir
      namelist: namelist
      geotable: geotable
    out: [logfiles, geofiles]

$namespaces:
  atmos: https://raw.githubusercontent.com/UoMResearchIT/atmos-tools-library/main/

