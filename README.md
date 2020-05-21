# ccEstimate

ccEstimate is a R package that estimates the monolayer confluency of induced pluripotent stem cells (iPSCs) in an unbiased way. 
Heterogeneity of growth rates across different iPSC lines may result in different confluency levels at the monolayer stage, with faster growing lines being more confluent, introducing biases and impacting differentiation outcome. 
To reduce biases due to different growth rates, ccEstimate provides a way to calculate confluency based on pictures of iPSCs cultured in monolayer. 

## Installation

Install ccEstimate in R:

```
devtools::install_github("s041629/ccEstimate")
```

Install EBImage:

```{r}
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("EBImage")
```


Load ccEstimate and EBImage:

```{r}
library(ccEstimate)
library(EBImage)
```

## Estimate confluency

Example input files (low and high confluency):

```
example_low_confluency  = system.file("extdata", "low_confluency.jpg" , package = "ccEstimate")
example_high_confluency = system.file("extdata", "high_confluency.jpg", package = "ccEstimate")
```

Display input files:

```
EBImage::display(EBImage::readImage(example_low_confluency ))
EBImage::display(EBImage::readImage(example_high_confluency))
```

Estimate confluency:

The ccEstimate function requires only an input file.

```
ccEstimate(example_low_confluency)
ccEstimate(example_high_confluency)
```

Calculate confluency on a specific number of sub-images (default = 100):

```
ccEstimate(example_low_confluency, n_random_images = 200)
```


## Citations

* D'Antonio-Chronowska A, Donovan MKR, Young Greenwald WW, Nguyen JP, Fujita K, Hashem S, Matsui H, Soncin F, Parast M, Ward MC, Coulet F, Smith EN, Adler E, D'Antonio M, Frazer KA. 
[Association of Human iPSC Gene Signatures and X Chromosome Dosage with Two Distinct Cardiac Differentiation Trajectories.](https://www.cell.com/stem-cell-reports/fulltext/S2213-6711(19)30361-3) 
Stem Cell Reports. 2019 Nov 12;13(5):924-938. doi: 10.1016/j.stemcr.2019.09.011. Epub 2019 Oct 24. PubMed PMID: [31668852](https://pubmed.ncbi.nlm.nih.gov/31668852/); PubMed Central PMCID: [PMC6895695](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6895695/).





