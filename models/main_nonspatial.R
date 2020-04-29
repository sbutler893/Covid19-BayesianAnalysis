# Model definition
description = "Main Model: All Predictors; non-spatial w/ random effect for state"


model_string <- textConnection("model{

  # Likelihood
  for(i in 1:n){
    Y[i]  ~ dnorm(mu[i] + S[state[i]], tau_y)
  }
  
  for (i in 1:n) {
    mu[i]   = inprod(X[i,], beta[])
    zero[i] = 0
  }
  
  # Priors
  for (j in 1:p) {
    beta[j] ~ dnorm(0, 0.01)
  }

  # Priors - state effects
  for(i in 1:s){
    S[i] ~ dnorm(0, tau_s)
  }

  tau_s ~ dgamma(0.1, 0.1)
  tau_y ~ dgamma(0.1, 0.1)

  sig[1] = 1 / sqrt(tau_y)
  sig[2] = 1 / sqrt(tau_s)

}")

# Define data and initial values

# Convert dataset to matrix form and drop non-numeric variables
X = data.matrix(df[,!(names(df) %in% c("FutureDeathsPer100k", "Date","StateName","StateID"))])
rownames(X) = seq(nrow(X))
print(head(X))

data <- list(
  n=nrow(X),
  p=ncol(X),
  s=length(unique(df$StateID)),
  Y=as.vector(df$FutureDeathsPer100k),
  state=as.vector(df$StateID),
  X=X
)

thin = 3
burnin = 100000
n.iter=300000
params  = c("beta", "sig", "S", "tau_s", "tau_y")
