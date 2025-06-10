# oliver-yanco-et-al-2025

Data analysis for publication: "Interacting effects of human mobility and landscape modification on wildlife"

[abstract]

[repo structure diagram]

### Data Availability

The wildlife movement data that serves as input for part 1 of the workflow are archived publicly on the [Movebank Data Repository](https://www.movebank.org/cms/movebank-content/data-repository) for reproducibility. See the manuscript's supplementary table 1 for DOIs and dataset contacts. Select species data could not be made public due to conservation concerns. The secondary data products used as input to part 2 of the workflow is publicly available on Dryad: [DOI ___](). These tabular data products contain all species and individuals in the analysis with environmental and anthropogenic annotations derived from the animal GPS locations.

### Part 1: Data Prep

Navigate to `src/workflow/workflow_part1.sh`

- Build database of wildlife movement data for 37 bird and mammal species pulled from [Movebank]((https://www.movebank.org/cms/movebank-main)) studies using `mosey_db` software. 
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

Navigate to `src/workflow/workflow_part2.sh`

- Fit space use interactive and additive models.
- Fit niche interactive and additive models.
- Fit intra-individual interactive and additive models for individuals with data in both 2019 and 2020.
- Select interactive or additive models based on significance.
- Produce model summaries and plot results.

### Development Environment

#### Python

This workflow was run with conda 24.11.1 and Python 3.12.8. With these installations on your machine, run the following commands in a terminal from the root of this repository to recreate our conda environment.

```
conda env create -f conda_envs/r_spatial2_direct_dependencies_environment.yml
```

#### R

This workflow was run with R 4.3.1. All necessary packages with specified versions can be installed with   [renv](https://rstudio.github.io/renv/articles/renv.html).

### Contributing

We welcome feedback and questions. Please open a new issue or create a fork of this repository.
