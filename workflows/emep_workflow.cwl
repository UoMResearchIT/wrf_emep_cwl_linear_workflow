cwlVersion: v1.2
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  MultipleInputFeatureRequirement: {}

inputs:
  namelist_emep:
    label: EMEP configuration file
    type: File
  metdir_emep:
    label: WRF Meteorological Files
    type:
      - "null"
      - Directory
  metfiles_emep:
    label: WRF Meteorological Files
    type:
      - "null"
      - type: array
        items: File
  metdir_name: string?
  inputdir_emep:
    label: EMEP Input Files
    type: Directory
  runlabel_emep:
    label: EMEP run label, for output files
    type: string
  emepcores: int
    
outputs:
  emeplogs:
    label: emep logfiles
    type:
      type: array
      items: File
    outputSource: step1_emep/output_logs
  emepout:
    label: output files
    type:
      type: array
      items: File
    outputSource: step1_emep/output_files


steps:
  step0_create_metdir:
    run: atmos:cwl/general/create_dir_from_filelist.cwl
    when: $(inputs.files !== null)
    in:
      files: metfiles_emep
      basename: metdir_name
    out: [dir]
  
  step1_emep:
    run: atmos:cwl/EMEP/emep.cwl
    in:
      namelist: namelist_emep
      inputdir: inputdir_emep
      metdir: 
        source:
          - step0_create_metdir/dir
          - metdir_emep
        pickValue: first_non_null
      runlabel: runlabel_emep
      cores: emepcores
    out: [output_files, output_logs]

$namespaces:
  atmos: https://raw.githubusercontent.com/UoMResearchIT/atmos-tools-library/main/

