library(targets)
library(geotargets)


# install.packages("geotargets", repos = "https://njtierney.r-universe.dev")
# install.packages( "sdmtools", repos = "https://idem-lab.r-universe.dev")
# remotes::install_github("geryan/irpreds")
# remotes::install_github("malaria-atlas-project/malariaAtlas") # CRAN version
# is wildly outdated
# install.packages("tidyterra")


tar_option_set(
  packages = c(
    "dplyr",
    "tibble",
    "terra",
    "malariaAtlas",
    "sdmtools",
    "irpreds",
    "geotargets",
    "tidyterra"
  ),
   format = "qs",
)

tar_source()

list(
  #### Static time-non-varying stuff
  tar_terra_rast(
    itn_2018,
    rast("data/spatial/ITN_2018_use_mean.tif")
  ),
  tar_terra_rast(
    ref,
    create_reference(itn_2018, "output/spatial/reference.tif")
  ),
  tar_target(
    cropyear,
    2010
  ),
  tar_target(
    crop_dir_2010,
    sprintf(
      "data/spatial/dataverse_files_crop_%s/spam%sv2r0_global_prod.geotiff/",
      cropyear,
      cropyear
    )
  ),
  tar_terra_rast(
    crop_2010_raw,
    get_crop(
      path = crop_dir_2010,
      sbst = "_A",
      cropyear
    )
  ),
  tar_terra_rast(
    crop_2010,
    match_ref(crop_2010_raw, ref)
  )
)
