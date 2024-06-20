library(targets)
library(geotargets)


# install.packages("geotargets", repos = "https://njtierney.r-universe.dev")
# install.packages( "sdmtools", repos = "https://idem-lab.r-universe.dev")
# # remotes::install_github("geryan/irpreds")
# remotes::install_github("malaria-atlas-project/malariaAtlas") #
# CRAN version of `malariaAtlas` is wildly outdated
# install.packages("tidyterra")


tar_option_set(
  packages = c(
    "dplyr",
    "tibble",
    "terra",
    "malariaAtlas",
    "sdmtools",
    "geotargets",
    "tidyterra",
    "tidyr",
    "purrr",
    "stringr",
    "readr"
  ),
   format = "qs",
)

tar_source()

list(
  #### Static time-non-varying stuff

  # reference - itn per capita mean
  tar_terra_rast(
    itn_2022,
    rast("data/spatial/nets_per_capita/ITN_2022_percapita_nets_mean.tif")
  ),
  tar_terra_rast(
    ref,
    create_reference(itn_2022, "output/spatial/reference.tif")
  ),

  ## crop data
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
    match_ref(
      x = crop_2010_raw,
      ref = ref,
      missing_val = 0,
      filename = "output/spatial/crop_2010.tif"
    )
  ),
  tar_terra_rast(
    crop_2010_std,
    std_rast(
      x = crop_2010,
      filename = "output/spatial/crop_2010_std.tif"
    )
  ),
  tar_terra_rast(
    crop_2010_scale,
    crop_2010 |>
      scale() |>
      writereadrast(
        x = _,
        filename = "output/spatial/crop_2010_scale.tif",
        overwrite = TRUE
      )
  ),

  # irrigation data
  tar_terra_rast(
    irrigation_2005,
    rast("data/spatial/irrigation_2005.asc") |>
      match_ref(ref = ref) |>
      writereadrast(
        x = _,
        filename = "output/spatial/irrigation_2005.tif",
        overwrite = TRUE
      )
  ),

  # pesticide data
  tar_terra_rast(
    pesticides_crop,
    import_rasts("data/spatial/pest_chemgrids/PEST-CHEMGRIDS_v1_01_CROPS/GEOTIFF/", ext = "tif") |>
      match_ref(ref = ref) |>
      writereadrast(
        x = _,
        filename = "output/spatial/pest_crop.tif",
        overwrite = TRUE
      )
  ),
  tar_terra_rast(
    pesticides_crop_scale,
    pesticides_crop |>
      std_rast(
        x = _,
        filename = "output/spatial/pest_crop_scale.tif"
      )
  ),
  tar_target(
    pesticide_tbls,
    prep_pesticides(ref)
  ),
  tar_target(
    all_pesticide_layers,
    expand_grid(
      pesticide_tbls[[1]],
      year = pesticide_tbls[[2]]$year |>
        unique()
    )
  ),
  tar_target(
    pesticide_classes,
    read_csv(
      file = "data/pesticide_classification.csv",
      col_names = c("pesticide", "type", "insecticide_class", "comment", "X"),
      col_select = c(pesticide, type, insecticide_class),
      skip = 1
    )
  ),
  tar_target(
    insecticide_tbl,
    pesticide_classes |>
      filter(type == "insecticide") |>
      select(- type) |>
      rename(
        insecticide = pesticide,
        class = insecticide_class
      )
  )


)


