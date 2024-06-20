ilt <- function(insecticide_tbl, all_pesticide_layers){

  insecticide_tbl |>
    left_join(
      y = all_pesticide_layers,
      by = c("insecticide" = "pesticide")
    ) |>
    mutate(
      fn = sprintf(
        "output/spatial/pesticides/%s_%s_%s.tif",
        insecticide,
        year,
        hl
      )
    )



}
