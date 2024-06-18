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
    # this line only for testing
    # filter(pesticide %in% c("Carbaryl", "Dimethoate")) |>
    mutate(
      filename = sprintf(
        "output/spatial/pesticides/%s_%s_%s.tif",
        pesticide,
        year,
        hl
      ),
      lyrname = sprintf(
        "%s_%s_%s",
        pesticide,
        year,
        hl
      ),
      r = pmap(
        .l = list(
          data = data,
          filename = filename,
          lyrname = lyrname

        ),
        .f = function(data, filename, lyrname, ref){
          data |>
            pull(f) |>
            rast() |>
            process_pesticide_rasts(
              x = _,
              ref = ref,
              filename = filename,
              lyrname = lyrname
            )
        },
        ref = ref
      )
    )

  mids <- all_rasts |>
    group_by(pesticide, year) |>
    summarise(
      r = do.call(c, r) |>
        list(),
      .groups = "drop"
    ) |>
    mutate(
      r = pmap(
        .l = list(
          pesticide = pesticide,
          year = year,
          r = r
        ),
        .f = function(pesticide, year, r){
          r |>
            mean() |>
            writereadrast(
              filename = sprintf(
                "output/spatial/pesticides/%s_%s_M.tif",
                pesticide,
                year
              ),
              overwrite = TRUE,
              layernames = sprintf(
                "%s_%s_M",
                pesticide,
                year
              )
            )

        }
      )
    )

  allr <- bind_rows(
    mids |>
      mutate(hl = "M") |>
      select(pesticide, year, hl, r),
    all_rasts |>
      select(pesticide, year, hl, r)
  ) |>
    arrange(pesticide, year, hl)

  # by year (all pesticides together)
  p_by_year <- allr |>
    # rename layer to pesticide
    mutate(
      r = map2(
        .x = pesticide,
        .y = r,
        .f = function(x, y){
          z <- y
          names(z) <- x
          z
        }
      )
    ) |>
    group_by(year, hl) |>
    summarise(
      r = do.call(c, r) |>
        list(),
      .groups = "drop"
    ) |>
    mutate(
      r = pmap(
        .l = list(
          year = year,
          hl = hl,
          r = r
        ),
        .f = function(year, hl, r){
          r |>
            writereadrast(
              filename = sprintf(
                "output/spatial/pesticides/year/%s_%s.tif",
                year,
                hl
              ),
              overwrite = TRUE
            )

        }
      )
    )

  # by pesticide (all years together)
  p_by_pesticide <- allr |>
    # rename layer to year
    mutate(
      r = map2(
        .x = year,
        .y = r,
        .f = function(x, y){
          z <- y
          names(z) <- x
          z
        }
      )
    ) |>
    group_by(pesticide, hl) |>
    summarise(
      r = do.call(c, r) |>
        list(),
      .groups = "drop"
    ) |>
    mutate(
      r = pmap(
        .l = list(
          pesticide = pesticide,
          hl = hl,
          r = r
        ),
        .f = function(pesticide, hl, r){
          r |>
            writereadrast(
              filename = sprintf(
                "output/spatial/pesticides/pesticide/%s_%s.tif",
                pesticide,
                hl
              ),
              overwrite = TRUE
            )
        }
      )
    )

  list(
    p_by_pesticide |>
      select(-r),
    p_by_year |>
      select(-r)
  )
}
