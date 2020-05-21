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



