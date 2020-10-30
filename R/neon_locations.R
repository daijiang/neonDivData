#' Information of all locations included in this data package.
#'
#' To reduce the size of this data package, we extracted location information from all
#' taxanomic groups and saved as one file to avoid duplications.
#'
#' @format A data frame with the following columns:
#'
#' - `domainID`: Unique identifier of the NEON domain.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name for terrestrial sites.
#' - `decimalLatitude`: The geographic latitude (in decimal degrees, WGS84) of the
#'     geographic center of the reference area.
#' - `decimalLongitude`: The geographic longitude (in decimal degrees, WGS84) of
#'     the geographic center of the reference area.
#' - `geodeticDatum`: Model used to measure horizontal position on the earth.
#' - `coordinateUncertainty`: The horizontal distance (in meters) from the given
#' decimalLatitude and decimalLongitude describing the smallest circle containing
#' the whole of the Location. Zero is not a valid value for this term.
#' - `elevation`: Elevation (in meters) above sea level.
#' - `elevationUncertainty`: Uncertainty in elevation values (in meters).
#' - `taxa`: The taxa group that the location information can be used for.
#' Note that some taxa groups may have the same 'plotID' but their
#' latitude/longitude may differ slightly, which justifies the need of this column.
#' - `neonDPI`: The NEON data product ID. See `neonUtilities:::table_types` for all
#' available data types and their data product IDs provided by NEON.
#' - `namedLocation`: Name of the measurement location in the NEON database.
#' - `aquaticSiteType`: Type of aquatic systems ('lake', 'river', 'stream').
#'
"neon_locations"
