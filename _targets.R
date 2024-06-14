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
  )#,
   #format = "qs",
)

tar_source()

list(
  #### Static time-non-varying stuff
  tar_terra_rast(
    itn2020,
    get_itn_2020("output/spatial/itn2020.tif")
  ),
  tar_target(
    crop_dir_2010,
    sprintf(
      "data/spatial/dataverse_files_crop_%s/spam%sv2r0_global_prod.geotiff/",
      2010,
      2010
    )
  ),
  # tar_terra_rast(
  #   crop_2010,
  #   import_rasts(
  #     path = crop_dir_2010,
  #     ext = ".tif"
  #   )
  # )
  tar_terra_rast(
    crop_2010,
    get_crop(
      path = crop_dir_2010,
      sbst = "_A"
    )
  )
)
