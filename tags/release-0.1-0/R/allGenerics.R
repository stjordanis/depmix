
# 
# Ingmar Visser, 23-3-2008
# 

.First.lib <- function(lib, pkg) {
	require(nnet)
}

.Last.lib <- function(libpath) {}

# Guess what: all generics

setGeneric("depmix", function(response,data=NULL,nstates,transition=~1,family=gaussian(),prior=~1,initdata=NULL,
		respstart=NULL,trstart=NULL,instart=NULL,ntimes=NULL, ...) standardGeneric("depmix"))

setGeneric("GLMresponse", function(formula, data = NULL, family = gaussian(), pstart =
                 NULL, fixed = NULL, prob=TRUE, ...) standardGeneric("GLMresponse"))

setGeneric("transInit", function(formula, nstates, data = NULL, family = multinomial(),
                 pstart = NULL, fixed = NULL, prob=TRUE, ...) standardGeneric("transInit"))

setGeneric("npar", function(object, ...) standardGeneric("npar"))

setGeneric("nobs", function(object, ...) standardGeneric("nobs"))

setGeneric("ntimes", function(object, ...) standardGeneric("ntimes"))

setGeneric("nstates", function(object, ...) standardGeneric("nstates"))

setGeneric("nresp", function(object, ...) standardGeneric("nresp"))

setGeneric("freepars", function(object, ...) standardGeneric("freepars"))

setGeneric("logLik", function(object, ...) standardGeneric("logLik"))

setGeneric("fit", function(object, ...) standardGeneric("fit"))

setGeneric("posterior", function(object, ...) standardGeneric("posterior"))

setGeneric("predict", function(object, ...) standardGeneric("predict"))

setGeneric("AIC", function(object, ..., k=2) standardGeneric("AIC"))

setGeneric("BIC", function(object, ...) standardGeneric("BIC"))

setGeneric("getdf",function(object) standardGeneric("getdf"))

setGeneric("setpars", function(object,values,which="pars",...) standardGeneric("setpars"))

setGeneric("getpars", function(object,which="pars",...) standardGeneric("getpars"))

setGeneric("logDens",function(object,...) standardGeneric("logDens"))

setGeneric("dens",function(object,...) standardGeneric("dens"))

setGeneric("summary")

setGeneric("ntimes", function(object, ...) standardGeneric("ntimes"))

setGeneric("nresp", function(object, ...) standardGeneric("nresp"))

