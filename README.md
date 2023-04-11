# WRF/EMEP Linear Workflow

Example Common Workflow Language (CWL) workflow and tool descriptors for running the 
Weather Research and Forecase (WRF) and EMEP models.

This workflow is designed for a single model domain. Example datasets for testing this 
workflow can be downloaded from Zenodo.


## Requirements:

* docker or singularity
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

Running the ERA5 download tool:
* Ensure to register for CDS service
* `cwltool --beta-dependency-resolvers-configuration ./dependency-resolvers-conf.yml cwl/era5_download.cwl --start_year 2017 --start_month 3 --start_day 3 --end_year 2017 --end_month 3 --end_day 3`

Running the Workflows:
* `cwltool --relax-path-checks cwl/wps_workflow.cwl wps_cwl_settings.yaml`
* `cwltool --relax-path-checks cwl/wrf_workflow.cwl wrf_real_cwl_settings.yaml`


## Notes

### WRF filenames

In order to work with singularity, all filenames need to exclude special characters.
To ensure that all WRF filenames comply with this requirement, you will need to add the 
`nocolons = .true.` option to your WPS, REAL and WRF namelists to ensure this.

### MPI parallisation

The WPS processes all run in single thread mode. REAL, WRF and EMEP have been compiled with
MPI parallisation. The default cores for each of these is 2, 9 and 9, respectively. The 
settings file can be edited to modify these requirements.

### Caching intermediate workflow steps

To cache the data from individual steps you can use the `--cachedir <cache-dir>` flag.


## License and Copyright 

These workflow scripts have been developed by the [Research IT](https://research-it.manchester.ac.uk/) 
at the [University of Manchester](https://www.manchester.ac.uk/).

Copyright 2023 [University of Manchester, UK](https://www.manchester.ac.uk/).

Licensed under the MIT license, see the LICENSE file for details.