## code to prepare `thekids_save` dataset goes here

layout_params <- rbind(c("quarter",        "_quart_portrait", "png", 1, 105,   297/2, "mm"),
                     c("half portrait",  "_half_portrait",  "png", 1, 210,   297/2, "mm"),
                     c("half landscape", "_half_landscape", "png", 1, 297/2, 210,   "mm"),
                     c("full portrait",  "_full_portrait",  "png", 1, 210,   297,   "mm"),
                     c("full landscape", "_full_landscape", "png", 1, 297,   210,   "mm"),
                     c("quarter",        "_quart_portrait", "pdf", 1, 105,   297/2, "mm"),
                     c("half portrait",  "_half_portrait",  "pdf", 1, 210,   297/2, "mm"),
                     c("half landscape", "_half_landscape", "pdf", 1, 297/2, 210,   "mm"),
                     c("full portrait",  "_full_portrait",  "pdf", 1, 210,   297,   "mm"),
                     c("full landscape", "_full_landscape", "pdf", 1, 297,   210,   "mm"))
colnames(layout_params) <- c("size", "suffix", "device", "scale", "width", "height", "units")
layout_params <- as.data.frame(layout_params)

usethis::use_data(layout_params, overwrite = TRUE)
