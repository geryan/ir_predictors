create_reference <- function(x, filename){

  idx <- which(!is.na(values(x)))

  x[idx] <- 0

  writeRaster(x, filename, overwrite = TRUE)

  rast(filename)

}
