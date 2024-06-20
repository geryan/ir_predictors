process_insecticides <- function(insecticide_lyr_tbl){

  ils <- insecticide_lyr_tbl |>
    mutate(
      r = map(
        .x = fn,
        .f = rast
      )
    )

  insecticide_std_avg <- ils |>
    group_by(hl, insecticide) |>
    summarise(
      r = do.call(c, r) |>
        list(),
      .groups = "drop"
    ) |>
    mutate(
      r = pmap(
        .l = list(
          insecticide = insecticide,
          hl = hl,
          r = r
        ),
        .f = function(insecticide, hl, r){
          r |>
            mean() |>
            std_rast() |>
            writereadrast(
              filename = sprintf(
                "output/spatial/insecticides/by_insecticide/%s_%s_std_avg.tif",
                insecticide,
                hl
              ),
              overwrite = TRUE,
              layernames = sprintf(
                "%s_%s",
                insecticide,
                hl
              )
            )
        }
      )
    )


  class_std_avg <- ils |>
    mutate(
      superclass = ifelse(
        class %in% c(
          "carbamate",
          "organochlorine",
          "organophosphate",
          "pyrethroid"
        ),
        class,
        "other"
      )
    ) |>
    group_by(hl, superclass) |>
    summarise(
      r = do.call(c, r) |>
        list(),
      .groups = "drop"
    ) |>
    mutate(
      r = pmap(
        .l = list(
          superclass = superclass,
          hl = hl,
          r = r
        ),
        .f = function(superclass, hl, r){
          r |>
            mean() |>
            std_rast() |>
            writereadrast(
              filename = sprintf(
                "output/spatial/insecticides/by_class/%s_%s_std_avg.tif",
                superclass,
                hl
              ),
              overwrite = TRUE,
              layernames = sprintf(
                "%s_%s",
                superclass,
                hl
              )
            )
        }
      )
    )

  insecticides_std_avg <- class_std_avg |>
    filter(hl == "M") |>
    mutate(
      r = map2(
        .x = r,
        .y = superclass,
        .f = set_layer_names
      )
    ) |>
    pull(r) |>
    rast() |>
    writereadrast(
      filename = "output/spatial/insecticides/by_class/insecticides_std_avg_m.tif",
    )

  NULL


  # now
  # averaged over years by insecticide standardised
  # averaged over years by class standardised


  # maybe later:
  # layers by year of insecticides
  # layers by insecticide by year
  # layer of class by year
  # layers of year by class
  # averaged over years by insecticide
  # averaged over years by class

}
