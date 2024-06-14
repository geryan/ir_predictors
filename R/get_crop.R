get_crop <- function(path, sbst = "_A", year){

  files <- gtools::mixedsort(list.files(path, pattern = ".tif"))

  pattern <- sprintf("%s.tif", sbst)

  files <- files[grepl(pattern, files)]

  rasts <- lapply(paste(path, files, sep = "/"), terra::rast)

  r <- do.call(c, rasts)

  lyrnames <- names(r)

  lyrnames <- lyrnames |>
    sub(
      pattern = sprintf(
        "spam%sV2r0_global_P_",
        year
      ),
      replacement = "",
      x = _
    ) |>
    sub(
      pattern = sbst,
      replacement = "",
      x = _
    )

  names(r) <- lyrnames

  r

}
