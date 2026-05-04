## code to prepare `thekids_colours`

library(colorspace)
library(datacolor)

# The list of primary colours for The Kids based off of "The Kids Brand Toolkit.pdf"
hex_colours = c('Saffron'='#F1B434',
                'Pumpkin'='#F56B00',
                'Teal'='#00A39C',
                'DarkTeal'='#00807A',
                'CelestialBlue'='#4A99DE',
                'AzureBlue'='#426EA8',
                'MidnightBlue'='#1F3B73',
                'CoolGrey'='#565F5F')


tint <- function(hex, pct) {
  mixed <- mixcolor(pct, hex2RGB(hex), hex2RGB("#FFFFFF"))
  hex(mixed)
}

# Named vector of colours
thekids_colours <- list()

for (colourname in names(hex_colours)) { # primary colours first
  thekids_colours[[tolower(colourname)]] = hex_colours[[colourname]]
}

tints <- c('50'=0.5, '10'=0.9)
for (tintname in names(tints)) { # tinted colours
  for (colourname in names(hex_colours)) {
    thekids_colours[[paste0(tolower(colourname), "_", tintname)]] = tint(hex_colours[[colourname]], pct=tints[[tintname]])
  }
}

thekids_palettes <- list(
  primary = hex_colours,
  tint50 = tint(hex_colours, pct = 0.5),
  tint10 = tint(hex_colours, pct = 0.9)
)

# Named vectors for each palette
pal_saffron <- colorspace::lighten(col = thekids_colours$saffron, amount = 95:10 / 100 )
pal_pumpkin <- colorspace::lighten(col = thekids_colours$pumpkin, amount = 95:5 / 100 )
pal_teal <- colorspace::lighten(col = thekids_colours$darkteal, amount = 95:0 / 100 )
pal_celestial <- colorspace::lighten(col = thekids_colours$celestialblue, amount = 95:0 / 100 )
pal_azure <- colorspace::lighten(col = thekids_colours$azureblue, amount = 95:0 / 100 )
pal_midnight <- colorspace::lighten(col = thekids_colours$midnightblue, amount = 95:0 / 100 )
pal_coolgrey <- colorspace::lighten(col = thekids_colours$coolgrey, amount = 95:-50 / 100 )

thekids_palettes$sequential <- list(
  primary = colorRampPalette(thekids_colours[c('midnightblue', 'azureblue', 'teal', 'saffron', 'pumpkin')]),
  tint50 = colorRampPalette(thekids_colours[c('midnightblue_50', 'azureblue_50', 'teal_50', 'saffron_50', 'pumpkin_50')]),
  tint10 = colorRampPalette(thekids_colours[c('midnightblue_10', 'azureblue_10', 'teal_10', 'saffron_10', 'pumpkin_10')]),
  saffron = colorRampPalette(pal_saffron),
  pumpkin = colorRampPalette(pal_pumpkin),
  teal = colorRampPalette(pal_teal),
  celestialblue = colorRampPalette(pal_celestial),
  azureblue = colorRampPalette(pal_azure),
  midnightblue = colorRampPalette(pal_midnight),
  coolgrey = colorRampPalette(pal_coolgrey)
)

pumpkin <- thekids_colours$pumpkin |> lighten(0.1) |> datacolor::hex2hcl()
celestial_blue <- thekids_colours$celestialblue |> datacolor::hex2hcl()
light_saffron <- thekids_colours$saffron |> lighten(0.9) |>  datacolor::hex2hcl()
saffron <- thekids_colours$saffron |> datacolor::hex2hcl()
darkteal <- thekids_colours$darkteal |> lighten(0.1) |> datacolor::hex2hcl()
midnight_blue <- thekids_colours$midnightblue |> datacolor::hex2hcl()
light_celestial_blue <- thekids_colours$celestialblue |> lighten(0.9) |> datacolor::hex2hcl()

pal_pumpkin2celestial <- colorspace::divergingx_hcl(
  n = 101,
  h1 = pumpkin[, "H"],
  c1 = pumpkin[, "C"],
  l1 = pumpkin[, "L"],
  h2 = light_saffron[, "H"],
  c2 = light_saffron[, "C"],
  l2 = light_saffron[, "L"],
  h3 = midnight_blue[, "H"],
  c3 = midnight_blue[, "C"],
  l3 = midnight_blue[, "L"]
)

pal_saffron2teal <- colorspace::divergingx_hcl(
    n = 101,
    h1 = saffron[, "H"],
    c1 = saffron[, "C"],
    l1 = saffron[, "L"],
    h2 = light_saffron[, "H"],
    c2 = light_saffron[, "C"],
    l2 = light_saffron[, "L"],
    h3 = darkteal[, "H"],
    c3 = darkteal[, "C"],
    l3 = darkteal[, "L"]
)


pal_saffron2midnight <- colorspace::divergingx_hcl(
  n = 101,
  h1 = saffron[, "H"],
  c1 = saffron[, "C"],
  l1 = saffron[, "L"],
  h2 = light_saffron[, "H"],
  c2 = light_saffron[, "C"],
  l2 = light_saffron[, "L"],
  h3 = midnight_blue[, "H"],
  c3 = midnight_blue[, "C"],
  l3 = midnight_blue[, "L"]
)

thekids_palettes$diverging <- list(
  pumpkin2celestial = colorRampPalette(pal_pumpkin2celestial),
  saffron2teal = colorRampPalette(pal_saffron2teal),
  saffron2midnight = colorRampPalette(pal_saffron2midnight)
)

usethis::use_data(thekids_palettes, thekids_colours, overwrite = TRUE)
