
# get c++ compiler talking with r and run a linear mixed effects model in
# template model builder (TMB)

# original code athor: jim thorson 
# any modifications: jocelyn.runnebaum@alaska.gov or jane.sullivan1@alaska.gov 
# last updated: 2017-10-13

setwd("~/adfg-vast/rtools_setup")

Use_REML = TRUE

# installing and running tmb ----

# modified instructions from @mcgowand

# update r (v 3.2.4)
install.packages("installr"); require(installr)
updateR()

# install Rtools package
# https://cran.r-project.org/bin/windows/Rtools/
# Default is to save directly to your C drive



# Install devtools, then run 'install_github("kaskr/adcomp/TMB")'. STOP the
# operation when it starts downloading Rtools.exe. You will receive an error msg
# saying it cancelled and didn't install properly. Run the install_github() line
# again.

# debug(utils:::unpackPkgZip) #use within ADFG to slow down the devtools package
# downloading process so the virus software can keep up (you may not need it)

# install.packages("devtools")
library(devtools)

install_github("kaskr/adcomp/TMB") # Hit the stop sign the first time!
library(TMB)

Version = "linear_mixed_model"
compile( paste0(Version,".cpp") )

# BONUS STEPS if you're still not able to compile: map system path to Rtools in
# your environmental vars (from Start menu, right click on 'Computer', select
# 'Properties', select 'Advanced system settings', select 'Environment
# Variables'. Under 'System variables,' scoll down to 'PATH' (or 'Path'),
# highlight it and select 'Edit.' Scroll to end of listed paths, and add the
# following paths to end of existing list using a semicolon to separate paths:
# "; C:\Rtools\gcc-4.6.3\bin") **WARNING** do not delete existing paths, just
# add the new one to the end of the existing list.  Restart R or Rstudio. 


# Compare with lme4 ----

# Simulate data
Factor = rep( 1:10, each=10)
Z = rnorm( length(unique(Factor)), mean=0, sd=1)
X0 = 0
Y = Z[Factor] + X0 + rnorm( length(Factor), mean=0, sd=1)


library(lme4)

Lme = lmer( Y ~ 1|factor(Factor), REML=Use_REML)
Data = list( "n_data"=length(Y), "n_factors"=length(unique(Factor)), "Factor"=Factor-1, "Y"=Y)
Parameters = list( "X0"=-10, "log_SD0"=2, "log_SDZ"=2, "Z"=rep(0,Data$n_factor) )
Random = c("Z")
if( Use_REML==TRUE ) Random = union( Random, "X0")

dyn.load( dynlib("linear_mixed_model") )
Obj = MakeADFun(data=Data, parameters=Parameters, random=Random)

# Prove that function and gradient calls work
Obj$fn( Obj$par )
Obj$gr( Obj$par )

# Optimize
start_time = Sys.time()
Opt = nlminb( start=Obj$par, objective=Obj$fn, gradient=Obj$gr, control=list("trace"=1) )
  Opt[["final_gradient"]] = Obj$gr( Opt$par )
  Opt[["total_time"]] = Sys.time() - start_time
  Report = Obj$report()
  SD = sdreport( Obj, bias.correct=TRUE )

# Compare estimates ----

# Global mean
c( fixef(Lme), Report$X0 )

# Global mean
cbind( "True"=Z, ranef(Lme)[['factor(Factor)']], Report$Z )

# Variances
summary(Lme)
unlist( Report[c("SDZ","SD0")] )

