# Model definition
description = "A test model"

model_string <- textConnection("model{
  
  # Likelihood
  for(i in 1:n){
    Y[i] ~ dnorm(mY[i], tau_y)
    mY[i] = b0 + b1*state.id[i] + q[days_since_sah[i]] 
  }
  
  # Priors - F effects
  for(i in 1:r){
    F[i] ~ dnorm(0, 0.001)
  }
  
  # Half-Cauchy prior
  # Gelman, 2008. https://arxiv.org/abs/0901.4011
  tau_y ~ dt(0, pow(2.5,-2), 1)T(0,)
  
  b0 ~ dnorm(0, 0.001)
  b1 ~ dnorm(0, 0.001)
  
  # WAIC calculations
  for(i in 1:n){
    like[i] = dnorm(Y[i], mY[i], tau_y)
  }
}")

# Define data and initial values
data <- list(
  n=length(unique(df$StateID)),
  s=length(unique(df$StateName)),
  Y=df$DeathsCumm,
  x=as.integer(df$parks_percent_change_from_baseline),
  q=df$days_since_sah,
  state=df$state.id
) 

thin = 5
burnin = 100000
n.iter=500000
params  = c("b0", "b1", "F", "tau_y")
