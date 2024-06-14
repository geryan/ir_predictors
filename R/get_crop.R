get_crop <- function(path, sbst = "_A"){

  files <- gtools::mixedsort(list.files(path, pattern = ".tif"))

  pattern <- sprintf("%s.tif", sbst)

  files <- files[grepl(pattern, files)]

  rasts <- lapply(paste(path, files, sep = "/"), terra::rast)

  do.call(c, rasts)


}
