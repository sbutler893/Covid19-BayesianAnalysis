# Applying Bayesian Analysis to COVID-19:
## What is helping to slow death rates?


Example (requires bash; will work on Linux/MacOS):

```
$ ./run testmodel
```

Otherwise, you can run the pipeline without a script by mirroring what is being done in the [`run`](run) script and running a command like the following:

```
Rscript --no-save --no-restore --verbose pipeline.R main_spatial
```

Replace `main_spatial` with the name of the model you want to run in the `models/` directory.
