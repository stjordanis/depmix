
# 
# Ingmar Visser, 23-3-2008
# 

# 
# DEPMIX.FITTED CLASS
# 

setClass("depmix.fitted",
	representation(message="character", # convergence information
		conMat="matrix", # constraint matrix on the parameters for general linear constraints
		posterior="data.frame" # posterior probabilities for the states
	),
	contains="depmix"
)

setMethod("fit",
	signature(object="depmix"),
	function(object,fixed=NULL,equal=NULL,conrows=NULL,conrows.upper=0,conrows.lower=0,method=NULL,...) {

		# when there are linear constraints donlp should be used
		# otherwise EM is good
		
		# can/does EM deal with fixed constraints??? it should be possible for sure
		if(is.null(method)) {
			if(object@stationary&is.null(equal)&is.null(conrows)) {
				method="EM"
			} else {
				method="donlp"
			}
		}
		
		# determine which parameters are fixed
		if(!is.null(fixed)) {
			if(length(fixed)!=npar(object)) stop("'fixed' does not have correct length")
		} else {
			if(!is.null(equal)) {
				if(length(equal)!=npar(object)) stop("'equal' does not have correct length")
				fixed <- !pa2conr(equal)$free
			} else {
				fixed <- getpars(object,"fixed")
			}
		}
		# set those fixed parameters in the appropriate submodels
		object <- setpars(object,fixed,which="fixed")
		
		if(method=="EM") {
			object <- em(object,verbose=TRUE,...)
		}
		
		if(method=="donlp") {
			# get the full set of parameters
			allpars <- getpars(object)
			# get the reduced set of parameters, ie the ones that will be optimized
			pars <- allpars[!fixed]
			
			# set bounds, if any
			par.u <- rep(+Inf, length(pars))
			par.l <- rep(-Inf, length(pars))
			
			# make loglike function that only depends on pars
			logl <- function(pars) {
				allpars[!fixed] <- pars
				object <- setpars(object,allpars)
				-logLik(object)
			}
			
			if(!require(Rdonlp2)) stop("donlp optimization requires the 'Rdonlp2' package")
			
			# make constraint matrix and its upper and lower bounds
			lincon <- matrix(0,nr=0,nc=npar(object))
			lin.u <- numeric(0)
			lin.l <- numeric(0)
			
			# incorporate equality constraints, if any
			if(!is.null(equal)) {
				if(length(equal)!=npar(object)) stop("'equal' does not have correct length")
				equal <- pa2conr(equal)$conr
				lincon <- rbind(lincon,equal)
				lin.u <- c(lin.u,rep(0,nrow(equal)))
				lin.l <- c(lin.l,rep(0,nrow(equal)))				
			}
			
			# incorporate general linear constraints, if any
			if(!is.null(conrows)) {
				if(ncol(conrows)!=npar(object)) stop("'conrows' does not have the right dimensions")
				lincon <- rbind(lincon,conrows)
				if(conrows.upper==0) {
					lin.u <- c(lin.u,rep(0,nrow(conrows)))
				} else {
					if(length(conrows.upper)!=nrow(conrows)) stop("'conrows.upper does not have correct length")
					lin.u <- c(lin.u,conrows.upper)
				}
				if(conrows.lower==0) {
					lin.l <- c(lin.l,rep(0,nrow(conrows)))
				} else {
					if(length(conrows.lower)!=nrow(conrows)) stop("'conrows.lower does not have correct length")
					lin.l <- c(lin.l,conrows.lower)
				}
			}
			
			# select only those columns of the constraint matrix that correspond to non-fixed parameters
			linconFull <- lincon
			lincon <- lincon[,!fixed]
			
			# set donlp2 control parameters
			cntrl <- donlp2.control(hessian=FALSE,difftype=2,report=TRUE)	
			
			mycontrol <- function(info) {
				return(TRUE)
			}
			
			# optimize the parameters
			result <- donlp2(pars,logl,
				par.upper=par.u,
				par.lower=par.l,
				A=lincon,
				lin.upper=lin.u,
				lin.lower=lin.l,
				control=cntrl,
				control.fun=mycontrol,
				...
			)
			
			class(object) <- "depmix.fitted"
			
			object@conMat <- linconFull
			object@message <- result$message
			
			# put the result back into the model
			allpars[!fixed] <- result$par
			object <- setpars(object,allpars)
			
		}
		
		object@posterior <- viterbi2(object)
		
		return(object)
	}
)

# convert conpat vector to rows of constraint matrix
pa2conr <- function(x) {
	fix=as.logical(x)
	x=replace(x,list=which(x==1),0)
	un=setdiff(unique(x),0)
	y=matrix(0,0,length(x))
	for(i in un) {
		z=which(x==i)
		for(j in 2:length(z)) {
			k=rep(0,length(x))
			k[z[1]]=1
			k[z[j]]=-1
			y=rbind(y,k)
		}
	}
	pa = list(free=fix,conr=y)
	return(pa)
}


setMethod("show","depmix.fitted",
	function(object) {
		cat("Convergence info:",object@message,"\n")
		print(logLik(object))
		cat("AIC: ", AIC(object),"\n")
		cat("BIC: ", BIC(object),"\n")
	}
)

setMethod("summary","depmix.fitted",
	function(object) {
		cat("Initial state probabilties model \n")
		print(object@prior)
		cat("\n")
		for(i in 1:object@nstates) {
			cat("Transition model for state (component)", i,"\n")
			print(object@transition[[i]])
			cat("\n")
		}
		cat("\n")
		for(i in 1:object@nstates) {
			cat("Response model(s) for state", i,"\n\n")
			for(j in 1:object@nresp) {
				cat("Response model for response",j,"\n")
				print(object@response[[i]][[j]])
				cat("\n")
			}
			cat("\n")
		}
	}
)

setMethod("posterior","depmix.fitted",
	function(object) {
		return(object@posterior)
	}
)
