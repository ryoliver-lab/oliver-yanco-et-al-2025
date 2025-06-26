# oliver-yanco-et-al-2025

Data analysis for publication: "Interacting effects of human mobility and landscape modification on wildlife"

### Abstract

Sustainable human-wildlife coexistence requires a mechanistic understanding of the many interacting ways in which humans affect animals. However, progress is hampered by the lack of accessible data for measuring the impact of the dynamic presence of people (hereafter ‘human mobility’). Here, we leverage daily mobile-device data to disentangle how human mobility and landscape modification differentially influence the use of geographic and environmental space for 37 mammal and bird species across the United States. Human mobility drove changes in area or niche size for over 65% of the species in this study. For ~60% of species that responded to human activities, the effects were interdependent – animals tended to react more strongly to human mobility in less modified habitats. Overall, human activities caused mammals and birds to use less space and shrink their environmental niches (mammals: median decrease in area and niche size of 10% and 3% per animal per week, respectively; birds: median decrease of 12% and 2%). Our results demonstrate that human mobility and landscape modification have complex combined effects on wildlife which need to be considered for effective management.

### Repository Structure

```
/oliver-yanco-et-al-2025 
  |  
  +--/src                 # Source code directory
  |   |
  |   +--config1.env      # config for repository filepaths and conda env
  |   |
  |   +--config2.env      # config for package libraries
  |   |
  |   +--/funs            # Source code for custom functions called by other scripts
  |   |   
  |   +--/hpc             # Scripts for submitting jobs to Slurm manager sequentially
  |   |
  |   +--/mosey           # Scripts for database annotation
  |   |
  |   +--/startup.R       # Source code for some basic environment configuration
  |   | 
  |   +--/workflow        # Scripts that execute elements of the workflow
  |       |
  |       +--part1_data_prep
  |       |
  |       +--part2_modeling
  |       |
  |       +--part3_figures
  |    
  +--/ctfs                # Control files for workflow scripts
  | 
  +--/conda_envs          # Stores .yml files with conda environment specifications
  |  
  +--/raw_data            # Raw data stored as initially received, inlcuding database
  |  
  +--/processed_data      # Processed data products
  |   |
  |   +--/intermediate_db_copies  # Working version of the database
  |   |   
  |   +--/safegraph
  |   |  |
  |   |  +--/counties-dates-2-10-22-reformatted
  |   |     |
  |   |     +--/daily-data
  |   |  
  |   |
  +--/out                 # Analytical outputs, interim products
  |    |
  |    +--/single_species_models  # Single species model .rdata files
  |    |   |
  |    |   +--/niche_interactive
  |    |   |
  |    |   +--/niche_additive
  |    |   |
  |    |   +--/area-interactive
  |    |   |
  |    |   +--/area_additive
  |    |
  |   +--/single_species_models_reruns
  |    |   |
  |    |   +--/niche_interactive
  |    |   |
  |    |   +--/niche_additive
  |    |   |
  |    |   +--/area_interactive
  |    |   |
  |    |   +--/area_additive
  |    |
  |    +--/model_diagnostics  # Single species model summary PDFs
  |    |   |
  |    |   +--/area
  |    |   |
  |    |   +--/niche
  |    |
  |    +--/model_diagnostics_reruns
  |    |   |
  |    |   +--/area
  |    |   |
  |    |   +--/niche
  |    |
  |    +--/safegraph_summary
  |    |
  |    +--/dbbmms         # Utilization distributions for individual-weeks
  |    |
  |    +--/event-annotation
  |    |
  |    +--/event-cbg-intersection
  |    |
  |    +--/covid-results  # Output CSVs from scripts in part3_model_effects.sh
  |    |
  |    +--/figures        # Output figure PNGs and PDFs
  |    |
  |    +--/intra-ind-models  # Models for species with sufficient data in both 2019 & 2020

```

### Data Availability

The wildlife movement data that serves as input for part 1 of the workflow are archived publicly on the [Movebank Data Repository](https://www.movebank.org/cms/movebank-content/data-repository) for reproducibility. See the manuscript's supplementary table 1 for DOIs and dataset contacts. Select species data could not be made public due to conservation concerns. The secondary data products used as input to part 2 of the workflow is publicly available on OSF: [DOI ___](). These tabular data products contain all species and individuals in the analysis with environmental and anthropogenic annotations derived from the animal GPS locations.

### Part 1: Data Prep

**R scripts:** `src/workflow/part1_data_prep`
**SLURM scripts:** `src/hpc/part1*.sh`

- Build database of wildlife movement data for 37 bird and mammal species pulled from [Movebank]((https://www.movebank.org/cms/movebank-main)) studies.
  - Data are stored as a [mosey_db](https://github.com/benscarlson/mosey_db), a SQLite relational database built to store data from [Movebank](www.movebank.org).
  - [This repository release](https://github.com/julietcohen/mosey_db/releases/tag/v1.0.0) includes the forked `mosey_db` code used to build the database used as input for this repository's workflow.
- Subset wildlife movement data to region and time period of interest.
- Annotate database with environmental layers for temperature, NDVI, and elevation.
- Annotate database with human mobility using daily mobile device counts.
- Annotate database with landscape modification based on a multi-year aggregated metric of anthropogenic modification. 
- Filter database for analysis minimum criteria.
- Clean database, including removing outlier events.
- Produce utilization distributions via dynamic Brownian bridge movement models for each individual-week combination.
- Estimate environmental niche size based on the pooled variance of multidimensional hypervolumes of the environmental conditions.

### Part 2: Modeling

Use tabular niche and space use estimations for each individual-week as input to species-specific Bayesian mixed effects models across all species.

**R scripts:** `src/workflow/part2_modeling`
**SLURM scripts:** `src/hpc/part2*.sh`

- Fit space use interactive and additive models.
- Fit niche interactive and additive models.
- Fit intra-individual interactive and additive models for individuals with data in both 2019 and 2020.
- Select interactive or additive models based on significance.
- Produce model summaries and plot results.

### Part 3: Figures

**R scripts:** `src/workflow/part3_figures`
**SLURM scripts:** `src/hpc/part3*.sh`

- Wildlife responses to the major components of human activity across the United States (Fig 1)
- Interacting effects of human activities on wildlife’s use of geographic and environmental space (Fig 2)
- Plastic behavioral responses to human mobility (Fig 3)
- Combined impact of human activities on wildlife use of geographic and environmental space (Fig 4) 
- Relationship between weekly area size and weekly sample size (Fig S1)
- Niche breadth subsample sizes (Fig S2)
- Fix rate median per species (Table S2)
- Posterior distributions of species-specific estimates (Figs S3 and S4):
  - effect of human mobility on area size 
  - interactive effect of human modification and human mobility on area size
  - effect of human mobility on niche size 
  - interactive effect of human modification and human mobility on niche size
- Distribution of census block sizes (Fig S5)
- Distribution of utilization distribution sizes (Fig S6)

### Development Environment

#### Python

This workflow was run with conda 24.11.1 and Python 3.12.8. With these installations on your machine, run the following commands in a terminal from the root of this repository to recreate our conda environment.

```
conda env create -f conda_envs/r_spatial2_direct_dependencies_environment.yml
```

#### R

This workflow was run with R 4.3.1. All necessary packages with specified versions can be installed with   [renv](https://rstudio.github.io/renv/articles/renv.html).

[renv documentation]

### Contributing

Contacts:

- Ruth Oliver rutholiver@ucsb.edu
- Scott Yanco yancos@si.edu

We welcome feedback and questions. Please open an issue or create a fork of this repository.
