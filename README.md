# VAST project set-up and exploration at ADF&G

VAST (Vector Autoregressive Spatio-Temporal model) is a spatio-temporal index standardization that can be used for single or multiple species. 

Original scripts and documentation:  
https://github.com/James-Thorson/VAST
http://www.FishStats.org

## Get started

*follow along in `rtools_setup.r`* 

### STEP 1: update R (v 3.2.4)
`install.packages("installr"); require(installr)`
`updateR()`

### STEP 2: install R tools
Rtools allows you to access your computer's c++ compiler. Install the most recent version of Rtools from https://cran.rproject.org/bin/windows/Rtools/. While running the Rtools setup .exe, there will be an option to 'Select Additional Tasks' - check the box below the 'Current value' to ensure that Rtools is listed in the system path. Use the default is to save Rtools directly to your C: drive. 

For details: https://github.com/stan-dev/rstan/wiki/Install-Rtools-for-Windows 

### STEP 3: install TMB

`install.packages("devtools")`
`library(devtools)`

Once devtools is installed, run `install_github("kaskr/adcomp/TMB")`. **STOP** the operation when it starts downloading the Rtools.exe. You will receive an error msg saying it cancelled and didn't install properly. Run `install_github()` again. 

`install_github("kaskr/adcomp/TMB")` **# Don't forget to hit the stop sign the first time!**
`library(TMB)`

### STEP 4: test your compiler 
In `rtools_setup.r`, we're using a simple linear mixed effects model example from https://github.com/James-Thorson/mixed-effects/tree/master/linear_mixed_model. 

### Bonus step if that didn't work... 
**Map system path to Rtools in your environmental vars**
From Start menu,  right click on 'Computer', select 'Properties', select 'Advanced system  settings', select 'Environment Variables'. Under 'System variables,' scoll down to 'PATH' (or 'Path'), highlight it and select 'Edit.' Scroll to end of listed paths, and add the following paths to end of existing list using a semicolon to separate paths: "; C:\Rtools\gcc-4.6.3\bin") **WARNING** do not delete existing paths, just add the new one to the end of the existing list. Restart R or Rstudio before trying **STEP 3** again.


