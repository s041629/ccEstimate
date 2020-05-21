# ccEstimate

ccEstimate is a R package that estimates the monolayer confluency of induced pluripotent stem cells (iPSCs) in an unbiased way. 
Heterogeneity of growth rates across different iPSC lines may result in different confluency levels at the monolayer stage, with faster growing lines being more confluent, introducing biases and impacting differentiation outcome. 
To reduce biases due to different growth rates, ccEstimate provides a way to calculate confluency based on pictures of iPSCs cultured in monolayer. 

## Installation

Install ccEstimate in R:

```
devtools::install_github("s041629/ccEstimate")
```

Load ccEstimate:

```
library(ccEstimate)
```

## Estimate confluency

Example input files (low and high confluency)

```
example_low_confluency  = system.file("extdata", "low_confluency.jpg" , package = "ccEstimate")
example_high_confluency = system.file("extdata", "high_confluency.jpg", package = "ccEstimate")
```

Display input files
