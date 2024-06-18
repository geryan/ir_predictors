prep_pesticides <- function(ref){

  all_rasts <- tibble(
    f = list.files(
      "data/spatial/pest_chemgrids/PEST-CHEMGRIDS_v1_01_APR/GEOTIFF/",
      pattern = ".tif",
      full.names = TRUE
    )
  ) |>
    mutate(
      fi = f |>
        sub(
          pattern = "*.tif",
          replacement = "",
          x = _
        ) |>
        sub(
          pattern = "data/spatial/pest_chemgrids/PEST-CHEMGRIDS_v1_01_APR/GEOTIFF/*",
          replacement = "",
          x = _
        ),
      z = str_split(fi, pattern = "_")
    ) |>
    unnest(z) |>
    select(-fi) |>
    filter(z != "APR") |>
    mutate(
      varnames = rep(
        c("crop", "pesticide", "year", "hl"),
        times = 1200
      )
    ) |>
    pivot_wider(
      id_cols = f,
      names_from = varnames,
      values_from = z
    ) |>
    nest(
      data = f,
      .by = c(pesticide, year, hl)
    ) |>
    filter(pesticide %in% c("Clothianidin", "Carbaryl", "Dimethoate")) |>
    mutate(
      filename = sprintf(
        "output/spatial/pesticides/%s_%s_%s.tif",
        pesticide,
        year,
        hl
      ),
      rast = map2(
        .x = data,
        .y = filename,
        .f = function(x, y, ref){
          x |>
            pull(f) |>
            rast() |>
            process_pesticide_rasts(
              x = _,
              ref = ref,
              filename = y
            )
        },
        ref = ref
      )
    )



}
