#!/usr/bin/env Rscript
format(Sys.time(), "%a %b %d %X %Y")
print(paste("[START]", Sys.time()))

library(rjags)
#library(plyr)

options(max.print=1000000)

# Parse command line args
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  print(paste("[FINISH]", Sys.time()))
  stop("At least one argument must be supplied: model", call.=FALSE)
}

# Print out config for logging
print_config = function() {
  print(paste("description:", description))
  print(paste("model_string:", model_string))
  print(paste("thin:", thin))
  print(paste("burnin:", burnin))
  print(paste("n.iter:", n.iter))
  print(paste("params:", params))
}

# Settings
model_dir = "./models"
out_dir = "./out"

# Construct model name and config file
# Note: each model defintion must be stored in a file named:
# ./models/<model_name>.R
modelname = args[1]
print(paste("model name:", modelname))
config_file = paste0(model_dir, "/", modelname, ".R")
print(paste("config file:", config_file))

# Load helper functions
source("util.R")
utiltest()

# Load COVID-19 dataset
df = load.covid.dataset()

inits = load.covid.inits(df)

# Load model-specific config file
source(config_file)
print_config()

r = jmodel.all(
  model_string=model_string, 
  data=data, 
  params=params, 
  # inits=inits, 
  burnin.iter=burnin, 
  n.iter=n.iter, 
  thin=thin
)
model = r[[1]]
samples = r[[2]]


print(getwd())
save_file = paste0(out_dir, "/", modelname, ".RData")
print(paste("Saving model, samples to:", save_file))
save(model, samples, file=save_file)
print("RData file saved.")

print(summary(samples, quantiles = c(0.025, 0.05, 0.5, 0.95, 0.975)))

evalsamples(samples)

evalmodel(model, n.iter, thin=thin)

print(paste("[FINISH]", Sys.time()))