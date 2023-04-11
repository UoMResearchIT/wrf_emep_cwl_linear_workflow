# WRF/EMEP Linear Workflow

Example Common Workflow Language (CWL) workflow and tool descriptors for running the 
Weather Research and Forecase (WRF) and EMEP models.

This workflow is designed for a single model domain. Example datasets for testing this 
workflow can be downloaded from Zenodo.


## Requirements:

* docker or singularity
* conda
* cwltool
* Toil - optional, useful for running on HPC or distributed computing systems

### CWL / Toil Installation:

The workflow runner (either cwltool, or Toil) can be installed using either conda or pip.
Environment files for conda are included, and can be used as shown below:
* cwltool only:
  * `conda env create --file install/env_cwlrunner.yml --name cwl`
* Toil & cwltool:
  * `conda env create --file install/env_toil.yml --name toil`

### Setup for Example Workflow

* Download the example dataset from Zenodo: https://doi.org/10.5281/zenodo.7817216
* Extract into the `input_files` directory:
  * `tar -zxvf wrf_emep_UK_example_inputs.tar.gz -C input_files --strip-components=1`

## Running the Workflow

The full workflow is broken into several logical steps:
1. ERA5 download
2. WPS 1st step: Geogrid geography file creation
3. WPS process: ungribbing of ERA5 data, and running of metgrid to produce meteorology files.
4. WRF process: generation of WRF input files by REAL, and running of WRF model
5. EMEP model: running of EMEP chemistry and transport model

Steps 1 and 3 require you to register with the CDS service, in order to download ERA5 data
before using in the WPS process.
Steps 2 and 5 require you to download extra input data - the instructions on how to do this
are included in the README.txt files in the relevant input data directories.

A full workflow for all steps is provided here. But each separate step can by run on it's 
own too, following the instructions given below. We recommend running step 4 first, to 
explore how the REAL & WRF workflow works, before trying the other steps.

### 1. ERA5 download.

Before running the ERA5 download tool, ensure that you have reqistered for the CDS service, 
signed the ERA5 licensing agreement, and saved the CDS API key (`.cdsapirc`) in your 
working directory.

To run the ERA5 download tool use the following command:
```
cwltool [--cachdir CACHE] [--singularity] workflows/era5_workflow.cwl example_workflow_configurations/era5_download_settings.yaml
```
Note that the `--cachedir CACHE` option sets the working directory cache, which enables the
reuse of any steps previously run (and the restarting of the workflow from this point).
The `--singularity` option is needed if you are using singularity instead of docker.

### 2. WPS: Geogrid geography file creation

Before running the geogrid tool you will need to download the geography data from the
[UCAR website](https://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html).
These should be extracted into the `input_files/geogrid_geog_input` directory.

To run the geogrid program use the following command:
```
cwltool [--cachdir CACHE] [--singularity] workflows/geogrid_workflow.cwl example_workflow_configurations/wps_geogrid_cwl_settings.yaml
```

### 3. WPS: Creation of meteorology input files

Before running the WPS process you will have to download the ERA5 datafiles (which will be
called `preslev_[YYYYMMDD].grib` and `surface_[YYYYMMDD].grib`) and copy these to the directory
`input_files/wps_era5_input`. If you have also run geogrid in step 2 you can replace the 
`geo_em.d01.nc` file in the `input_files/wps_geogrid_input` directory with the file that 
geogrid created.

To run the wps metgrid process use the following command:
```
cwltool [--cachdir CACHE] [--singularity] workflows/wps_workflow.cwl example_workflow_configurations/wps_metgrid_cwl_settings.yaml
```

### 4. WRF: Creation of WRF input files, and running WRF model

The WRF model can be run without any prepreparation, except for the downloading of the 
input data from Zenodo. However, if you have created new meteorology files (`met_em*`) using
WPS you can replace the files in the `input_files/wrf_met_input` directory with these.

To run the WRF process (including REAL) use the following command:
```
cwltool [--cachdir CACHE] [--singularity] workflows/wrf_workflow.cwl example_workflow_configurations/wrf_real_cwl_settings.yaml
``` 

### 5. EMEP: Running EMEP chemistry and transport model

Before running the EMEP model you will need to download the EMEP input dataset. This can be
done using the `catalog.py` tool, following the instructions in the `input_files/emep_input/README.txt`
file. If you have run WRF you can also replace the `wrfout*` data files in the 
`input_Files/emep_wrf_input` directory with those you have created.

To run the EMEP model use the following command:
```
cwltool [--cachdir CACHE] [--singularity] workflows/emep_workflow.cwl example_workflow_configurations/emep_cwl_settings.yaml
```

### Full Workflow


## Notes

### WRF filenames

In order to work with singularity, all filenames need to exclude special characters.
To ensure that all WRF filenames comply with this requirement, you will need to add the 
`nocolons = .true.` option to your WPS, REAL and WRF namelists to ensure this.

### MPI parallel processing

The WPS processes all run in single thread mode. REAL, WRF and EMEP have been compiled with
MPI support. The default cores for each of these is 2, 9 and 9, respectively. The 
settings file can be edited to modify these requirements.

### Caching intermediate workflow steps

To cache the data from individual steps you can use the `--cachedir <cache-dir>` optional flag.


## License and Copyright 

These workflow scripts have been developed by the [Research IT](https://research-it.manchester.ac.uk/) 
at the [University of Manchester](https://www.manchester.ac.uk/).

Copyright 2023 [University of Manchester, UK](https://www.manchester.ac.uk/).

Licensed under the MIT license, see the LICENSE file for details.