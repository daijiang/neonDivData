#' Data product last modification time
#'
#' This data frame records the last modify time for each data product in this package.
#'
#' @format A data frame with the following columns:
#' - `taxa`: The taxa group that the location information can be used for.
#' Note that some taxa groups may have the same 'plotID' but their
#' latitude/longitude may differ slightly, which justifies the need of this column.
#' - `neonDPI`: The NEON data product ID. See `neonUtilities:::table_types` for all
#' available data types and their data product IDs provided by NEON.
#' - `modify_time`: The last modification time.
#'
"data_modify_time"
