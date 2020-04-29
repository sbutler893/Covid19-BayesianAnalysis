# Helper functions for ST540 Group Project - Jonathan E. McMahon

utiltest = function() {
  print("util.R loaded successfully.")
}

load.covid.dataset = function(lag.days=(2*7)) {
  # lag.days sets the relationship in days between the current day and a future new death count 
  # lag.days = (2*7)
  print(paste("Lag (in days):", lag.days))
  
  df = read.csv("./data/DataConsolidation.csv", header=TRUE)
  print(dim(df))
  
  # Drop rows for states with less than 10 total deaths
  predrop = nrow(df)
  df = df[df$StatesLessThan10Deaths=="Include",]
  print(paste("Dropped", predrop - nrow(df), "rows for states with <10 total deaths."))
  print(dim(df))
  
  # Lower-case state name to match convention in adjacency matrix
  df$StateName = tolower(df$StateName)
  states = sort(unique(df$StateName))
  print(paste("States:",length(states)))
  print(states)
  
  # Feature StateID uniquely identifies each state 
  # NOTE: THIS MUST COME AFTER ALL DROPPING OF STATES!
  df["StateID"] = 0
  for (i in 1:length(states)) {
    df[df$StateName == states[i],"StateID"] = i
  }
  
  # Convert to date type
  df$Date = as.Date(df$Date, "%m/%d/%Y")
  dates = sort(unique(df$Date))

  df$FutureDeaths = 0
  for (s in states) {
    for (i in seq(length(dates)-lag.days)) {
      df[(df$Date == dates[i] & df$StateName == s),"FutureDeaths"] = df[(df$Date == dates[i] + 14 & df$StateName == s),"NewDeaths"]
    }
    df[(df$StateName == s),"FutureDeathsPer100k"] = df[(df$StateName == s),"FutureDeaths"] / (df[(df$StateName == s),"Pop2020"] / 100000)
  }
  
  keep_cols = c(
    "Date",
    "FutureDeathsPer100k",
    "DaysSince10DeathsCumm",
    "StateName",
    "StateID",
    "density_p.sq.mi",
    "MedianAge",
    "StayAtHome_DaysSinceEff", 
    "NonEssBizClosure_DaysSinceEff", 
    "SchoolClosure_DaysSinceEff",
    "retail_and_recreation_percent_change_from_baseline",
    "grocery_and_pharmacy_percent_change_from_baseline",
    "parks_percent_change_from_baseline",
    "transit_stations_percent_change_from_baseline", 
    "workplaces_percent_change_from_baseline",
    "residential_percent_change_from_baseline"
  )
  
  # Drop unused columns
  df = df[,keep_cols]
  
  # Rename the retained columns
  names(df)[names(df) == "DaysSince10DeathsCumm"] = "DaysSince10Deaths"
  names(df)[names(df) == "density_p.sq.mi"] = "PopDensity"
  names(df)[names(df) == "StayAtHome_DaysSinceEff"] = "StayAtHome"
  names(df)[names(df) == "NonEssBizClosure_DaysSinceEff"] = "BizClosure"
  names(df)[names(df) == "SchoolClosure_DaysSinceEff"] = "SchoolClosure"
  names(df)[names(df) == "retail_and_recreation_percent_change_from_baseline"] = "RetailAndRecPctChg"
  names(df)[names(df) == "grocery_and_pharmacy_percent_change_from_baseline"] = "GroceryPharmacyPctChg"
  names(df)[names(df) == "parks_percent_change_from_baseline"] = "ParksPctChg"
  names(df)[names(df) == "transit_stations_percent_change_from_baseline"] = "TransitPctChg"
  names(df)[names(df) == "workplaces_percent_change_from_baseline"] = "WorkplacesPctChg"
  names(df)[names(df) == "residential_percent_change_from_baseline"] = "ResidentialPctChg"

  # Drop rows where there is no response data (FutureDeathsPer100k) due to lag
  date_cutoff = max(df$Date) - lag.days
  print(paste("Dropping rows with dates after", date_cutoff))
  predrop = nrow(df)
  df = df[df$Date <= date_cutoff,]
  print(paste("Dropped", predrop - nrow(df), "rows."))
  print(paste("Final dataframe is:", dim(df)))
  
  print(summary(df))
  return(df)
}

# TODO - if we need to init our parameters
load.covid.inits = function(df) {
  return (list())
}

dic = function(model, n.iter, thin) {
  DIC    <- dic.samples(model, n.iter=n.iter, thin=thin, progress.bar="text")
  print(DIC)
  rm(DIC)
}

waic = function(model, n.iter, thin) {
  waic.samples = coda.samples(model, variable.names=c("like"), thin=thin, n.iter=n.iter, progress.bar="text")
  like   <- rbind(waic.samples[[1]], waic.samples[[2]])
  rm(waic.samples)
  fbar   <- colMeans(like)
  Pw     <- sum(apply(log(like), 2, var))
  WAIC   <- (-2 * sum(log(fbar))) + (2 * Pw)
  print(paste(WAIC,Pw))
  rm(like)
}

evalmodel = function(model, n.iter, thin=1) {
  # Compute DIC
  print(paste("Computing DIC ...","( thin =",thin,")"))
  dic(model, n.iter, thin)
  # Compute WAIC
  print("Computing WAIC / Pw ...")
  waic(model, n.iter, thin)
}

evalsamples = function(samples) {
  print("ESS:")
  print(effectiveSize(samples))
  print("Gelman Diagnostic:")
  print(gelman.diag(samples))
}


jmodel.burnin = function(model_string, data, burnin.iter, n.iter, inits=NA) {

  # Instantiate model
  print("Instantiating model...")
  model <- jags.model(
    model_string,
    data=data, 
    inits=inits,
    n.chains=2,
    quiet=FALSE
  )
  
  # Burn in
  print(paste("Burn-in for", burnin.iter, "iterations..."))
  update(model, n.iter, progress.bar="text")
  print(paste("Burn-in complete"))
  return(model)
}

jmodel.sample = function(model, params, n.iter, thin) {
  # Draw samples
  print(paste("Sampling for", n.iter, "iterations..."))
  samples = coda.samples(
    model, 
    variable.names=params, 
    n.iter=n.iter,
    thin=thin,
    progress.bar="text"
  )
  return(samples)
}

jmodel.all = function(model_string, data, params, burnin.iter, n.iter, inits=c(), thin=1) {
  model = jmodel.burnin(model_string, data, burnin.iter, n.iter, inits=inits)
  samples = jmodel.sample(model, params, n.iter, thin)
  return(list(model, samples))
}
