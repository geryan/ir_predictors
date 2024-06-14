get_itn_2020 <- function(filename){

  itn <- malariaAtlas::getRaster("Explorer__2020_Africa_ITN_Use")

  names(itn) <- "itn_2020"

  writeRaster(
    itn,
    filename = filename
  )

  rast(filename)

}
