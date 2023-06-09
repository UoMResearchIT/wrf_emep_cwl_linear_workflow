cwlVersion: v1.2
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  MultipleInputFeatureRequirement: {}


inputs:
  namelist_real:
    label: Real preprocessor Configuration File
    type: File
  namelist_wrf:
    label: WRF Configuration File
    type: File
  metdir:
    label: Meteorological Files (directory)
    type:
      - "null"
      - Directory
  metfiles:
    label: Meteorological Files (list)
    type:
      - "null"
      - type: array
        items: File
  realcores: int
  wrfcores: int
  generate_rundir: boolean
    
    
outputs:
  wrflogs:
    label: wrf logfiles
    type:
      type: array
      items: File
    outputSource: step4_wrf/output_logs
  wrfout:
    label: output files
    type:
      type: array
      items: File
    outputSource: step4_wrf/output_wrfout


steps:
  step0_rundir:
    run: atmos:cwl/WRF/create_run_dir.cwl
    in:
      generate_rundir: generate_rundir
    out: [rundir]

  step1_metfile_list:
    label: if we are given a directory containing metfiles, extract these to make an array of files
    when: $(inputs.directory !== null)
    run: atmos:cwl/general/extract_filelist_from_dir.cwl
    in:
      directory: metdir
    out: [filelist]

  step3_real:
    run: atmos:cwl/WRF/real.cwl
    in:
      namelist: namelist_real
      metfiles:
        source:
          - step1_metfile_list/filelist
          - metfiles
        pickValue: first_non_null
      rundir: step0_rundir/rundir
      cores: realcores
    out: [output_wrfinput, output_wrfbdy, output_wrflowinput, output_wrffdda, output_logs]
    
  step4_wrf:
    run: atmos:cwl/WRF/wrf.cwl
    in:
      namelist: namelist_wrf
      wrfinputs: step3_real/output_wrfinput
      wrfbdys: step3_real/output_wrfbdy
      wrflowinputs: step3_real/output_wrflowinput
      wrffddas: step3_real/output_wrffdda
      rundir: step0_rundir/rundir
      cores: wrfcores
    out: [output_wrfout, output_logs]

$namespaces:
  atmos: https://raw.githubusercontent.com/UoMResearchIT/atmos-tools-library/main/

