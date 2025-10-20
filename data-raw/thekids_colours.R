## code to prepare `thekids_colours`

library(colorspace)

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

# Named vectors for each palette
thekids_palettes <- list(
  primary = hex_colours,
  tint50 = tint(hex_colours, pct = 0.5),
  tint10 = tint(hex_colours, pct = 0.9),
  typography = c('CoolGrey' = hex_colours[['CoolGrey']],
                 'CoolGrey50' = tint(hex_colours[['CoolGrey']], pct = 0.5),
                 'CoolGrey10' = tint(hex_colours[['CoolGrey']], pct = 0.9))
)

usethis::use_data(thekids_palettes, thekids_colours, overwrite = TRUE)
