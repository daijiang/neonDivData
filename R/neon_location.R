#' Information of all locations included in this data package.
#'
#' We extracted location information from all
#' taxanomic groups and saved as one file here.
#' _Note that some aquatic sites do not have lat/long information though._
#'
#' @format A data frame with the following columns:
#'

#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the
#'     geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of
#'     the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name for terrestrial sites.
#' - `aquaticSiteType`: Type of aquatic systems ('lake', 'river', 'stream').
#'
"neon_location"
