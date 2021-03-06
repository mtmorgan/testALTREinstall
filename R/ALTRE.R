#' Workflow: Post-alignment to altered enhancers and promoters
#'
#' This workflow takes aligned reads and peak/hotspot calls from
#' assays of open chromatin (ATAC-seq and Dnase-seq) and identifies
#' regions (enhancers and promoters) that differ based on cell and
#' tissue type.
#'
#' ALTRE requires sample information CSV file, peak files (bed format),
#' and alignment bam files (BAM) as input
#'
#' Workflow Steps: The following is the order in which the functions should be used:
#' (Click on function to get more detailed information)
#' \enumerate{
#'
#' \item  \code{\link{loadBedFiles}}
#'
#' Takes in a sample information file (CSV), loads peak files, and outputs a
#' GRangesList object that holds all peaks for each sample type.
#'
#' \item  \code{\link{getConsensusPeaks}}
#'
#' Takes in a sample peaks list (output from loadBedFiles in step 2), and outputs
#' consensus peaks. Consensus peaks are those present in at least N replicates.
#' A barplot summary of the number of consensus peaks and those in each replicate,
#' use plotConsensusPeaks().
#'
#' \item \code{\link{combineAnnotatePeaks}}
#'
#' The GRanges for all sample types from the previous step are combined and annotated with
#' type specificity (which cell types the hotspot is present in) and
#' whether each region represented in the GRanges is a promoter (default: <1500bp from
#' a transcription start site) or an enhancer (>1500bp from a transcription
#' start site). Function can also merge regulatory regions that are within a specified
#' distance from each other.  This function requires the annotation of
#' transcription start sites (e.g. to retrieve from Ensembl, run TSS <- getTSS()))
#'
#' \item \code{\link{getCounts}}
#'
#' The number of reads overlapping all regions for each cell type is calculated.
#' To view a density plot of the sizes of the regions, use the function plotgetcounts().
#'
#' \item \code{\link{countanalysis}}
#'
#' Identify significantly altered regulatory elements (promoters or enhancers).
#'  A volcano plot of these significantly altered regulatory elements can be
#'  viewed by running the function plotCountAnalysis().
#'
#' \item \code{\link{comparePeaksAltre}}
#'
#' This function compares the number of regulatory regions identified as altered
#'  or shared between two sample types.  The two methods compared are:
#'  1) using peak presence and associated intensity (e.g. amount of chromatin accessibility);
#'  2) using peak presence only as determined by peak/hotspot caller.
#'
#' \item \code{\link{pathenrich}}
#'
#' Determine which pathways are overrepresented in altered promoters and enhancers.
#' }
#' @docType package
#' @name ALTRE
#' @import methods
#' @import IRanges
#' @import S4Vectors
#' @import GenomicRanges
#' @import ggplot2
NULL
