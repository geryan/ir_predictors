process_pesticide_rasts <- function(x, ref, filename){

  v <- values(x)

  v <- ifelse(v < 0, 0, v)

  if(dim(v)[2] > 1){
    v <- apply(
      X = v,
      MARGIN = 1,
      FUN = sum
    )
  }

  y <- x[[1]]

  y[] <- v


  y |>
    match_ref(
      ref = ref
    ) |>
    writereadrast(
    filename = filename,
    overwrite = TRUE
  )

}
