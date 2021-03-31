#' Site information
#'
#' Full names, types, coordinates of all 81 NEON sites.
#'
#' @format A data frame with the following columns:
#'
#' - `Site Name`: Full site name.
#' - `siteID`: NEON site code.
#' - `Domain Name`: Full domain name.
#' - `domainID`: Unique identifier of the NEON domain.
#' - `State`: The state name of the site locates in.
#' - `Latitude`: Latitide of the site  (in decimal degrees, WGS84).
#' - `Longitude`: Longitude of the site (in decimal degrees, WGS84).
#' - `Site Type`: The type of the site (e.g. Core Terrestrial).
#' - `Site Subtype`: Second level site type, for aquatic sites only (e.g. Lake, Wadeable Stream, Non-wadeable River).
#' - `Site Host`: Host organization of the site.
#'
"neon_sites"
