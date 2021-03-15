library(tidyverse)
library(neonDivData)
library(usmap)
library(sf)

# us map ----
usmap::plot_usmap("states", labels = FALSE)

pr = rnaturalearth::ne_countries(scale = "large", country = "puerto rico", returnclass = "sf")
plot(sf::st_geometry(pr))

pr2 = st_cast(pr, "POLYGON")[4,] %>%
  st_transform(crs = usmap_crs()@projargs)
plot(sf::st_geometry(pr2))

pr3 = sf::st_coordinates(pr2) %>%
  as.data.frame() %>%
  mutate(X = X - 1200000,
         Y = Y + 120000)

us_map = usmap::plot_usmap("states", labels = FALSE) +
  geom_polygon(data = pr3, aes(x = X, y = Y), size = 0.38,
               fill = "white", color = "black")

# plant species richness ----
sp_rich_plant = data_plant %>%
  group_by(siteID) %>%
  summarise(nspp = n_distinct(taxon_id), .groups = "drop")
# get latitude and longitude of all sites
sp_rich_plant = left_join(sp_rich_plant,
                          filter(neon_location, location_id %in% data_plant$location_id) %>%
                            # each site has multiple plots with slightly different lat/long
                            group_by(siteID) %>%
                            summarise(latitude = mean(latitude),
                                      longitude = mean(longitude),
                                      .groups = "drop"),
                          by = "siteID")
sp_rich_plant = select(sp_rich_plant, longitude, latitude, siteID, nspp)
sp_rich_plant_transf = usmap_transform(sp_rich_plant)


p1 = us_map +
  geom_jitter(data = filter(sp_rich_plant_transf, longitude < -70),
              width = 0.8,
              aes(x = longitude.1, y = latitude.1,
                  color = nspp,
                  size = nspp)) +
  geom_jitter(data = filter(sp_rich_plant_transf, longitude > -70) %>%
                mutate(longitude.1 = longitude.1 - 1200000,
                       latitude.1 = latitude.1 + 120000),
              width = 0.8,
              aes(x = longitude.1, y = latitude.1,
                  color = nspp,
                  size = nspp)) +
  # colorspace::scale_color_continuous_divergingx(palette = "Geyser", rev = T) +
  colorspace::scale_color_continuous_sequential(palette = "Viridis", rev = T, begin = 0.1) +
  labs(#title = "Plant species richness at NEON sites",
       color = "Species\nRichness",
       size = "Species\nRichness") +
  theme(legend.position = c(0.9, 0.25),
        legend.background = element_rect(colour = NA, fill = NA),
        legend.box = "vertical")

p2 = ggplot(mutate(sp_rich_plant_transf, island = ifelse(siteID %in% c("LAJA", "GUAN", "PUUM"), "Y", "N")),
            aes(x = latitude, y = nspp)) +
  geom_jitter(width = 1.2, size = 0.9, aes(color = island), show.legend = FALSE) +
  geom_smooth(method = "lm") +
  labs(x = "Latitude", y = "Species Richness") +
  scale_color_manual(values = c("Y" = "red", "N" = "black"))

p_plant = p1 +
  # patchwork::inset_element(p2, left = 0.3, bottom = 0.7, right = 0.62, top = 1)
  patchwork::inset_element(p2, left = 0.55, bottom = 0, right = 0.8, top = 0.23) +
  theme_classic()

ggsave("manuscript/figures/p_plant.pdf", plot = p_plant, width = 10, height = 7)
ggsave("manuscript/figures/p_plant.png", plot = p_plant, width = 10, height = 7)

# # fish ----
# table(neon_taxa$taxon_group)
#
# sp_rich_fish = data_fish %>%
#   group_by(siteID) %>%
#   summarise(nspp = n_distinct(taxonID))
# summary(sp_rich_fish$nspp)
# sp_rich_fish = left_join(sp_rich_fish,
#                           filter(neon_locations, taxa == "fish") %>%
#                             group_by(siteID) %>%
#                             summarise(latitude = mean(latitude, na.rm = T),
#                                       longitude = mean(longitude, na.rm = T))) %>%
#   filter(!siteID %in% c("BIGC", "TECR")) # no lat/long for these two sites...
# sp_rich_fish = select(sp_rich_fish, longitude, latitude, siteID, nspp)
# sp_rich_fish_transf = usmap_transform(sp_rich_fish)
#
# p1_fish = us_map +
#   geom_jitter(data = filter(sp_rich_fish_transf, longitude < -70),
#               width = 0.8,
#               aes(x = longitude.1, y = latitude.1,
#                   color = nspp,
#                   size = nspp)) +
#   geom_jitter(data = filter(sp_rich_fish_transf, longitude > -70) %>%
#                 mutate(longitude.1 = longitude.1 - 1200000,
#                        latitude.1 = latitude.1 + 120000),
#               width = 0.8,
#               aes(x = longitude.1, y = latitude.1,
#                   color = nspp,
#                   size = nspp)) +
#   # colorspace::scale_color_continuous_divergingx(palette = "Geyser", rev = T) +
#   colorspace::scale_color_continuous_sequential(palette = "Viridis", rev = T, begin = 0.1) +
#   labs(#title = "Plant species richness at NEON sites",
#     color = "Species\nRichness",
#     size = "Species\nRichness") +
#   theme(legend.position = c(0.9, 0.25),
#         legend.background = element_rect(colour = NA, fill = NA),
#         legend.box = "vertical")
#
# p2_fish = ggplot(mutate(sp_rich_fish_transf, island = ifelse(siteID %in% c("CUPE", "GUIL"), "Y", "N")),
#             aes(x = latitude, y = nspp)) +
#   geom_jitter(width = 1.2, aes(color = island), show.legend = FALSE) +
#   geom_smooth(method = "lm") +
#   labs(x = "Latitude", y = "Species Richness") +
#   scale_color_manual(values = c("Y" = "red", "N" = "black"))
#
# p_fish = p1_fish +
#   # patchwork::inset_element(p2, left = 0.3, bottom = 0.7, right = 0.62, top = 1)
#   patchwork::inset_element(p2_fish, left = 0.55, bottom = 0, right = 0.8, top = 0.23) +
#   theme_classic()
#
# ggsave("manuscript/figures/p_fish.pdf", plot = p_fish, width = 10, height = 7)
# ggsave("manuscript/figures/p_fish.png", plot = p_fish, width = 10, height = 7)

# Species accumulation figure for Beetles ----

library(iNEXT)
library(lubridate)

# Load beetle data product

# Generate a separate year column from collectDate
data_beetle <- mutate(data_beetle, Year = year(observation_datetime))

# Subset data for ORNL
ORNLbeetle <- filter(data_beetle, siteID == "ORNL")

# See what date range of sampling has been (2014-2020)
range(ORNLbeetle$observation_datetime)

# Get number of individuals across entire sampling time ranked by genus
gtosubsp <- filter(ORNLbeetle, taxon_rank %in% c("genus", "species", "subspecies"))

# create a vector of genus names for all records from ORNL and append to gtosubsp dataframe
gtosubsp <- mutate(gtosubsp,
                   genus = gsub("^([^ ]*) .*$", "\\1", x = taxon_name),
                   species = gsub("^([^ ]* [^ ]*).*$", "\\1", x = taxon_name)
                   )
# genus <- rep(NA, length = dim(gtosubsp)[1])
# for(i in 1:dim(gtosubsp)[1]){
#   genus[i] <- strsplit(gtosubsp$scientificName[i], ' ')[[1]][1]
# }
# gtosubsp <- cbind(gtosubsp, genus)

# # create a vector of species names for all records from ORNL and append to gtosubsp dataframe
# species <- rep(NA, length = dim(gtosubsp)[1])
# for(i in 1:dim(gtosubsp)[1]){
#   species[i] <- strsplit(gtosubsp$scientificName[i], ' ')[[1]][2]
# }
# gtosubsp <- cbind(gtosubsp, species)

# Create vectors of abundances by genus, species, and subspecies
by_genus <- gtosubsp %>%
  group_by(genus) %>%
  summarise(count = n(), .groups = "drop")

by_species <- gtosubsp %>%
  group_by(species) %>%
  summarise(count = n(), .groups = "drop")

by_subspecies <- gtosubsp %>%
  group_by(taxon_name) %>%
  summarise(count = n(), .groups = "drop")

# Put taxonomic rank by abundance summaries into a list as required by iNEXT functions
by_rank <- list(genus = by_genus$count, species = by_species$count, subspecies = by_subspecies$count)

# Create iNEXT object for ORNL beetle data
out <- iNEXT(by_rank, q = c(0, 1, 2), datatype = "abundance")

# Plot species diversity of orders q=0,1,2 for different taxnomic subsets
beetle_rarefac <- ggiNEXT(out, type = 1, facet.var = "site")

beetle_rarefac = beetle_rarefac +
  theme(legend.position = c(0.1, 0.75))

# Export pdf to GitHub
ggsave("~/GitHub/neonDivData/manuscript/figures/beetle_rarefaction.pdf", plot = beetle_rarefac, width = 10.5, height = 5)
ggsave("~/GitHub/neonDivData/manuscript/figures/beetle_rarefaction.png", plot = beetle_rarefac, width = 10.5, height = 5)

