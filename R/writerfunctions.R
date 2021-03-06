
#' Writes annotated genomic regions
#'
#' Creates a CSV file with genomic regions annoted as promotor or enhances
#' categorized by cell type
#'
#' @param countsPeaks output generated from getCounts()
#' @param con connection filepath
#'
#' @examples
#' \dontrun{
#' dir <- system.file('extdata', package='ALTRE', mustWork=TRUE)
#' csvfile <- file.path(dir, 'lung.csv')
#' sampleinfo <- loadCSVFile(csvfile)
#' samplePeaks <- loadBedFiles(sampleinfo)
#' consPeaks <- getConsensusPeaks(samplepeaks=samplePeaks,minreps=2)
#' TSSannot <- getTSS()
#' consPeaksAnnotated <- combineAnnotatePeaks(conspeaks = consPeaks,
#'                                           TSS = TSSannot,
#'                                           merge = TRUE,
#'                                           regionspecific = TRUE,
#'                                           mergedistenh = 1500,
#'                                           mergedistprom = 1000 )
#' #Need to run getcounts on all chromosomes
#' countsPeaks <- getcounts(annotpeaks = consPeaksAnnotated,
#'                              csvfile = csvfile,
#'                              reference = 'SAEC')
#' con <- "annotatedRegions.csv"
#' writeAnnotatedRegions(countsPeaks, con)
#' }
#' @export
writeAnnotatedRegions <-
  function(countsPeaks, con) {
    annotatedRegions <-
      GenomicRanges::as.data.frame(countsPeaks$consPeaksAnnotated)
    readr::write_csv(annotatedRegions, con)
  }


#' Creates a custom track for visualization on genome browser
#'
#' Creates a color-coded BED file for visualization of peaks and their ALTRE
#' categories in a genome browser: red indicates increased log2fold change/low
#' p-value, blue indicates decreased lod2fold change/low p-value, and purple
#' indicates regions with little to no change and insignificant p-values.
#' Based on the log2fold change and p-value inputs, there is a possibility that
#' some regions will not fulfill any of the supplied criteria
#' ("in-between" shared and type-specific). They are colored grey.
#'
#' @param analysisresults output generated from categAltrePeaks()
#' @param con connection
#'
#' @examples
#' \dontrun{
#' dir <- system.file('extdata', package='ALTRE', mustWork=TRUE)
#' csvfile <- file.path(dir, 'lung.csv')
#' sampleinfo <- loadCSVFile(csvfile)
#' samplePeaks <- loadBedFiles(sampleinfo)
#' consPeaks <- getConsensusPeaks(samplepeaks=samplePeaks,minreps=2)
#' TSSannot <- getTSS()
#' consPeaksAnnotated <- combineAnnotatePeaks(conspeaks = consPeaks,
#'                                           TSS = TSSannot,
#'                                           merge = TRUE,
#'                                           regionspecific = TRUE,
#'                                           mergedistenh = 1500,
#'                                           mergedistprom = 1000)
#' #Need to run getcounts on all chromosomes
#' counts_consPeaks <- getcounts(annotpeaks = consPeaksAnnotated,
#'                              csvfile = csvfile,
#'                              reference = 'SAEC')
#' altre_peaks <- countanalysis(counts = counts_consPeaks,
#'                              pval = 0.01,
#'                              lfcvalue = 1)
#' categaltre_peaks <- categAltrePeaks(altre_peaks, lfctypespecific = 1.5,
#'	lfcshared = 1.2, pvaltypespecific = 0.01, pvalshared = 0.05)
#' writeBedFile(categaltre_peaks)
#' }
#' @export

writeBedFile <-
  function(analysisresults, con) {

    analysisresults <- analysisresults[[1]]
    if (is.data.frame(analysisresults) == FALSE) {
      stop("The input for the analysisresults arguement is not a dataframe!")
    }

    colors <- c("grey", "salmon", "green", "blue")

    mycol <- analysisresults$REaltrecateg
    mycol[which(mycol == "Ambiguous")] <-
      paste(as.numeric(grDevices::col2rgb(colors[1])),
            sep = ",",
            collapse = ",")
    mycol[which(mycol == "Shared")] <-
      paste(as.numeric(grDevices::col2rgb(colors[2])),
            sep = ",",
            collapse = ",")
    mycol[which(mycol == "Reference Specific")] <-
      paste(as.numeric(grDevices::col2rgb(colors[3])),
            sep = ",",
            collapse = ",")
    mycol[which(mycol == "Experiment Specific")] <-
      paste(as.numeric(grDevices::col2rgb(colors[4])),
            sep = ",",
            collapse = ",")

    bedfile <- data.frame(
      chrom = analysisresults$chr,
      chromStart  = analysisresults$start,
      chromEnd = analysisresults$stop,
      name = paste0("peak", 1:nrow(analysisresults)),
      score = "0",
      strand = "+",
      thickStart = ".",
      thickEnd = ".",
      itemRgb = mycol
    )

    header <-
      'track name=ALTREtrack description="ALTRE categories" visibility=2 itemRgb="On"'

    utils::write.table(
      header,
      file = con,
      row.names = FALSE,
      col.names = FALSE,
      quote = FALSE
    )

    utils::write.table(
      bedfile,
      file = con,
      row.names = FALSE,
      col.names = FALSE,
      append = TRUE,
      quote = FALSE,
      sep = "\t"
    )

  }

#' Writes a data table generated by comparePeaksAltre
#'
#' Creates a CSV file containing a data table
#'
#' @param comparePeaksOut output generated from comparePeaksAltre()
#' @param con connection filepath
#'
#' @examples
#' \dontrun{
#' dir <- system.file('extdata', package='ALTRE', mustWork=TRUE)
#' csvfile <- file.path(dir, 'lung.csv')
#' sampleinfo <- loadCSVFile(csvfile)
#' samplePeaks <- loadBedFiles(sampleinfo)
#' consPeaks <- getConsensusPeaks(samplepeaks=samplePeaks,minreps=2)
#' TSSannot <- getTSS()
#' consPeaksAnnotated <- combineAnnotatePeaks(conspeaks = consPeaks,
#'                                           TSS = TSSannot,
#'                                           merge = TRUE,
#'                                           regionspecific = TRUE,
#'                                           mergedistenh = 1500,
#'                                           mergedistprom = 1000)
#' #Need to run getcounts on all chromosomes
#' counts_consPeaks <- getcounts(annotpeaks = consPeaksAnnotated,
#'                              csvfile = csvfile,
#'                              reference = 'SAEC')
#'                              #' altre_peaks <- countanalysis(counts = counts_consPeaks,
#'                              pval = 0.01,
#'                              lfcvalue = 1)
#' categaltre_peaks <- categAltrePeaks(altre_peaks,
#'                                     lfctypespecific = 1.5,
#'                                     lfcshared = 1.2,
#'                                     pvaltypespecific = 0.01,
#'                                     pvalshared = 0.05)
#' comparePeaksOut <- comparePeaksAltre(categaltre_peaks, reference= 'SAEC')
#' con <- "datatableRE.csv"
#' writeREdf(comparePeaksOut, con)
#'
#' }
#' @export

writeREdf <-
  function(comparePeaksOut, con) {
    fileOut <- tibble::rownames_to_column(as.data.frame(comparePeaksOut[[1]]))
    readr::write_csv(fileOut, con)
  }


#' Writes a data generated by pathenrich
#'
#' Creates  three CSV files containing the results of pathenrichments for
#' experimental, reference, and shared
#'
#' @param pathenrichOut output generated from pathenrich()
#' @param con connection filepath
#'
#' @examples
#' \dontrun{
#' dir <- system.file('extdata', package='ALTRE', mustWork=TRUE)
#' csvfile <- file.path(dir, 'lung.csv')
#' sampleinfo <- loadCSVFile(csvfile)
#' samplePeaks <- loadBedFiles(sampleinfo)
#' consPeaks <- getConsensusPeaks(samplepeaks=samplePeaks,minreps=2)
#' TSSannot <- getTSS()
#' consPeaksAnnotated <- combineAnnotatePeaks(conspeaks = consPeaks,
#'                                           TSS = TSSannot,
#'                                           merge = TRUE,
#'                                           regionspecific = TRUE,
#'                                           mergedistenh = 1500,
#'                                           mergedistprom = 1000)
#' #Need to run getcounts on all chromosomes
#' counts_consPeaks <- getcounts(annotpeaks = consPeaksAnnotated,
#'                              csvfile = csvfile,
#'                              reference = 'SAEC')
#'                              #' altre_peaks <- countanalysis(counts = counts_consPeaks,
#'                              pval = 0.01,
#'                              lfcvalue = 1)
#' categaltre_peaks <- categAltrePeaks(altre_peaks,
#'                                     lfctypespecific = 1.5,
#'                                     lfcshared = 1.2,
#'                                     pvaltypespecific = 0.01,
#'                                     pvalshared = 0.05)
#' comparePeaksOut <- comparePeaksAltre(categaltre_peaks, reference= 'SAEC')
#'
#'
#' MFenrich <- pathenrich(analysisresults = altre_peaks,
#'                        ontoltype = 'MF',
#'                        enrichpvalfilt = 0.01)
#' con <- "pathEnrichMF.zip"
#' writePathEnrich(pathenrichOut = MFenrich, con = con)
#' }
#' @export

writePathEnrich <-
  function(pathenrichOut, con) {

    fileExt <- tools::file_ext(con)
    listNames <- names(pathenrichOut)
    fileCon <- stringr::str_replace(con,
                                    fileExt ,
                                    stringr::str_c(listNames,
                                                   "csv",
                                                   sep = "."))
    mapply(readr::write_csv, pathenrichOut, fileCon)

    utils::zip(zipfile = con, files = fileCon)
    #if(file.exists(con)) {
    #  file.rename(paste0(con, ".zip"), con)}
    #tar(pathenrichOut,fileCon)

  }

