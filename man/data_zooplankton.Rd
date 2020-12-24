% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data_zooplankton.R
\docType{data}
\name{data_zooplankton}
\alias{data_zooplankton}
\title{Zooplankton density data}
\format{
A data frame (also a tibble) with the following columns:
\itemize{
\item \code{siteID}: NEON site code.
\item \code{namedLocation}:	Name of the measurement location in the NEON database.
\item \code{sampleID}: Identifier for sample.
\item \code{samplerType}:	Type of sampler used to collect the sample.
\item \code{subsampleType}:	Indicates type of subsample generated.
\item \code{taxonID}: Species code, based on one or more sources.
\item \code{scientificName}:	Scientific name, associated with the taxonID. This is the name
of the lowest level taxonomic rank that can be determined.
\item \code{taxonRank}: The lowest level taxonomic rank that can be determined for the individual or specimen.
\item \code{density}: Density of zooplankton, with unit to be count per liter.
\item \code{collectDate}: Date of the collection event.
\item \code{zooMinimumLength}: Minimum length of individuals in zooplankton taxonomic group subsample (millimeter).
\item \code{zooMaximumLength}: Maximum length of individuals in zooplankton taxonomic group subsample (millimeter).
\item \code{zooMeanLength}: Mean length of individuals in zooplankton taxonomic group subsample (millimeter).
}
}
\usage{
data_zooplankton
}
\description{
This dataset was derived from \href{https://data.neonscience.org}{NEON data portal} with data product ID 'DP1.20219.001'. Details about this data product can be found at \url{https://data.neonscience.org/data-products/DP1.20219.001}. Zooplankton are collected from the water column of lakes near NEON sensor infrastructure. The type of sampler used depends on the depth of water at the sampling location. Multiple tows or traps are collected at each location and composited into a single sample. Zooplankton sampling is quantitative and based on the volume of water collected during sampling.
}
\details{
Here, we:
\itemize{
\item Only keep those with \code{sampleCondition} to be "condition OK" for the \code{zoo_taxonomyProcessed} table.
\item Combined the \code{zoo_fieldData} and the \code{zoo_taxonomyProcessed}.
\item Calculated zooplankton density as the ratio of \code{adjCountPerBottle} and \code{towsTrapsVolume}.
}
}
\note{
Details of locations (e.g. latitude/longitude coordinates can be found in \link{neon_locations}).
}
\author{
Lara Jansen; Stephanie Parker
}
\keyword{datasets}