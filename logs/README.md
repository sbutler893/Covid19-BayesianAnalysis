# Logs Guide #

Below is a brief summary of the log files in this directory.

| *log file*   | *description* |
|--------------|---------------|
| [`main_spatial_xburn_2020-04-25_163217`](main_spatial_xburn_2020-04-25_163217.log) | main spatial model |
| [`main_spatial_scaled_300k_2020-04-25_171930`](main_spatial_scaled_300k_2020-04-25_171930.log) | main spatial model, with scaled `X` |
| [`main_spatial_scaled_300k_nodays_2020-04-26_011655`](main_spatial_scaled_300k_nodays_2020-04-26_011655.log) | main spatial model, with scaled `X` (without `DaysSince10Deaths`) |
| [`main_spatial_bernoulli_2020-04-25_162906`](main_spatial_bernoulli_2020-04-25_162906.log) | variable selection |
| [`main_spatial_bernoulli_nodays_2020-04-26_011629`](main_spatial_bernoulli_nodays_2020-04-26_011629.log) | variable selection (without `DaysSince10Deaths`) |
| [`main_spatial_only_mobility_100k_2020-04-25_174724`](main_spatial_only_mobility_100k_2020-04-25_174724.log) | only mobility indicators |
| [`main_spatial_only_non_mobility_300k_2020-04-25_162533`](main_spatial_only_non_mobility_300k_2020-04-25_162533.log) | everything except mobility indicators |
| [`main_spatial_only_non_mobility_300k_nodays_2020-04-26_011605`](main_spatial_only_non_mobility_300k_nodays_2020-04-26_011605.log) | everything except mobility indicators (without `DaysSince10Deaths`) |
| [`main_nonspatial_2020-04-25_182204`](main_nonspatial_2020-04-25_182204.log) | non-spatial model (random effects for state) |
| [`main_nonspatial_nodays_2020-04-26_011545`](main_nonspatial_nodays_2020-04-26_011545.log) | non-spatial model (random effects for state) (without `DaysSince10Deaths`) |

Other logs from older runs are located in [`archive`](./archive).