# Model definition
description = "Main Model - All predictors scaled"

# Create an adjacency matrix for the states in the US
# source: https://www4.stat.ncsu.edu/~reich/BSMdata/Guns.html
library(spdep)
library(maptools)
library(maps)
usa.state = map(database="state", fill=TRUE, plot=FALSE)
state.ID <- sapply(strsplit(usa.state$names, ":"), function(x) x[1])
usa.poly = map2SpatialPolygons(usa.state, IDs=state.ID)
usa.nb = poly2nb(usa.poly)
A = nb2mat(usa.nb, style="B")
M <- diag(rowSums(A))

# Remove from adjacency matrix any states that are not in our dataset
for (i in seq(nrow(A))) {
  if (!(rownames(A)[i] %in% unique(df$StateName))) {
    A = A[-i,]
    A = A[,-i]
  }
}

model_string <- textConnection("model{

  # Likelihood
  for(i in 1:n){
    Y[i]  ~ dnorm(mu[i] + S[state[i]], tau_y)
  }
  # s is the number of states
  S[1:s] ~ dmnorm(zero[1:s], tau_s * Omega[1:s, 1:s])

  for (i in 1:n) {
    mu[i]   = inprod(X[i,], beta[])
    zero[i] = 0
  }
  Omega[1:s, 1:s] = M[1:s, 1:s] - rho * A[1:s, 1:s]
  
  # Priors
  for (j in 1:p) {
    beta[j] ~ dnorm(0, 0.01)
  }
  tau_y ~ dgamma(0.1, 0.1)
  tau_s ~ dgamma(0.1, 0.1)
  rho  ~ dunif(0, 1)

  sig[1] = 1 / sqrt(tau_y)
  sig[2] = 1 / sqrt(tau_s)

}")

# Define data and initial values

# Convert dataset to matrix form and drop non-numeric variables
X = data.matrix(df[,!(names(df) %in% c("FutureDeathsPer100k", "Date","StateName","StateID"))])
rownames(X) = seq(nrow(X))
print(head(X))

# Scale X
X = scale(X)

data <- list(
  n=nrow(X),
  p=ncol(X),
  s=length(unique(df$StateID)),
  Y=as.vector(df$FutureDeathsPer100k),
  state=as.vector(df$StateID),
  A=A,
  M=M,
  X=X
)

thin = 3
burnin = 50000
n.iter=300000
params  = c("beta", "sig", "tau_y")
