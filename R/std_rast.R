std_rast <- function(x, filename = NULL, overwrite = TRUE){
  if(nlyr(x)>1){

    vals <- values(x)

    nvs <- apply(
      vals,
      MARGIN = 2,
      FUN = function(x){
        x/max(x, na.rm = TRUE)
      }
    )

    r <- x

    r[] <- nvs


  } else {
    r <- x / max(x)
  }

  if(is.null(filename)){
    return(r)
  }

  writereadrast(
    r,
    filename,
    overwrite
  )
}
