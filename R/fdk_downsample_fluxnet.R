#' Down sample half-hourly data to daily values
#'
#' Currently CO2 fluxes can not be down sampled using the
#' FLUXNET routine due to missing methodology.
#'
#' @param df FLUXNET based HH data frame
#' @param out_path where to store the converted data if converted to
#'  fluxnet formatting
#'
#' @return data frame with daily (DD) down sampled values
#' @export

fdk_downsample_fluxnet <- function(
    df,
    site,
    out_path
){

  # Using the FLUXNET instructions, however in some cases there will
  # be no equivalence giving missing information. Downsampled data should
  # therefore note be considered equal to the origianl FLUXNET/ONEFLUX
  # processing chain.
  # https://fluxnet.org/data/fluxnet2015-dataset/fullset-data-product/

  df <- df |>
    mutate(
      date = as.Date(TIMESTAMP_START, "%Y%m%d%H%M")
    )

  start_year <- format(min(df$date), "%Y")
  end_year <- format(max(df$date), "%Y")

  df <- df |>
    group_by(date) |>
    summarize(

      # METEO

      # precipitation is the sum of HH values
      P_F = sum(P_F, na.rm = TRUE),

      # temperature is the mean of the HH values
      TA_F_MDS = mean(TA_F_MDS, na.rm = TRUE),

      # temperature is the mean of the HH values
      SW_IN_F_MDS = mean(SW_IN_F_MDS, na.rm = TRUE),

      # short wave radiation is the mean of the HH values
      SW_IN_F_MDS = mean(SW_IN_F_MDS, na.rm = TRUE),

      # long wave radiation is the mean of the HH values
      LW_IN_F_MDS = mean(LW_IN_F_MDS, na.rm = TRUE),

      # VPD is the mean of the HH values
      VPD_F_MDS = mean(VPD_F_MDS, na.rm = TRUE),

      # wind speed is the mean of the HH values
      WS_F = mean(WS_F, na.rm = TRUE),

      # temperature is the mean of the HH values
      PA_F = mean(PA_F, na.rm = TRUE),

      # CO2 is the mean of the HH values
      CO2_F_MDS = mean(CO2_F_MDS, na.rm = TRUE),

      # FLUXES

      # NETRAD/USTAR/SW_out is average from HH data
      # (only days with more than 50% records available)
      NETRAD = ifelse(
          length(which(!is.na(NETRAD)) > length(NETRAD) * 0.5 ),
          mean(NETRAD, na.rm = TRUE),
          NA
        ),

      USTAR = ifelse(
        length(which(!is.na(USTAR)) > length(USTAR) * 0.5 ),
        mean(USTAR, na.rm = TRUE),
        NA
      ),

      SW_OUT = ifelse(
        length(which(!is.na(SW_OUT)) > length(SW_OUT) * 0.5 ),
        mean(SW_OUT, na.rm = TRUE),
        NA
      ),

      # Latent heat is the mean of the HH values
      LE_F_MDS = mean(LE_F_MDS, na.rm = TRUE),
      LE_CORR = mean(LE_CORR, na.rm = TRUE),

      # sensible heat is the mean of the HH values
      H_F_MDS = mean(H_F_MDS, na.rm = TRUE),
      H_CORR = mean(H_CORR, na.rm = TRUE),

      # Joint uncertainty (can't be produced from)
      # available data in a similar manner as described
      # in fluxnet docs
      LE_CORR_JOINTUNC = NA,
      H_CORR_JOINTUNC = NA,

      # All carbon fluxes follow complex reprocessing
      # as Model Efficiency is repeated for each time
      # aggregation

      # MODIS RS data
      LAI = mean(LAI, na.rm = TRUE),
      FPAR = mean(FPAR, na.rm = TRUE)

    )

  # save data to file, using FLUXNET formatting
  if (!missing(out_path)) {

    filename <- sprintf("FLX_%s_PLUMBER_FULLSET_DD_%s_%s_2-3.csv",
                        site,
                        start_year,
                        end_year
    )
    filename <- file.path(
      out_path,
      filename
    )

    utils::write.table(
      df,
      file = filename,
      quote = FALSE,
      col.names = TRUE,
      row.names = FALSE,
      sep = ","
    )

    message("---> writing data to file:")
    message(sprintf("   %s", filename))

  } else {
    # return the merged file
    return(df)
  }
}
