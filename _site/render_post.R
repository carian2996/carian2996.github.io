#!/usr/bin/env Rscript

input <- commandArgs(trailingOnly = TRUE)
KnitPost <- function(input, base.url = "/") {
    require(knitr)
    opts_knit$set(base.url = base.url)
    fig.path <- paste0("../figs/", sub(".Rmd$", "", basename(input)), "/")
    opts_chunk$set(fig.path = fig.path)
    opts_chunk$set(fig.cap = "center")
    render_jekyll()
    print(paste0("../_posts/", sub(".Rmd$", "", basename(input)), ".markdown"))
    knit(input, output = paste0("../_posts/", Sys.Date(), '-', sub(".Rmd$", "", basename(input)), ".markdown"), envir = parent.frame())
}

KnitPost(input)