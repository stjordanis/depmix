# 
# Maarten Speekenbrink 23-3-2008
# 

rdirichlet <- function(n, alpha) {
  # taken from gtools...
    l <- length(alpha)
    x <- matrix(rgamma(l * n, alpha), ncol = l, byrow = TRUE)
    sm <- x %*% rep(1, l)
    x/as.vector(sm)
}

which.is.max <- function(x) {
    # taken from MASS
    y <- seq_along(x)[x == max(x)]
    if(length(y) > 1L) sample(y, 1L) else y
}


ind.max <- function(x) {
    out <- rep(0,length(x))
    out[which.is.max(x)] <- 1
    out
}

em <- function(object,...) {
	if(!is(object,"mix")) stop("object is not of class '(dep)mix'")
	call <- match.call()
	if(is(object,"depmix")) {
		call[[1]] <- as.name("em.depmix")
	} else {
		call[[1]] <- as.name("em.mix")
	}
	object <- eval(call, parent.frame())
	object
}

# em for lca and mixture models
em.mix <- function(object,maxit=100,tol=1e-8,crit="relative",random.start=TRUE,verbose=FALSE,classification=c("soft","hard"),...) {
	
	clsf <- match.arg(classification)
	
	if(!is(object,"mix")) stop("object is not of class 'mix'")
		
	ns <- nstates(object)
	ntimes <- ntimes(object)
	lt <- length(ntimes)
	et <- cumsum(ntimes)
	bt <- c(1,et[-lt]+1)
	
	converge <- FALSE
	j <- 0
	
	if(random.start) {
				
		nr <- sum(ntimes(object))
		gamma <- rdirichlet(nr,alpha=rep(.01,ns))
		
		if(clsf == "hard") {
		    gamma <- t(apply(gamma,1,ind.max))
		}

		LL <- -1e10
		
		for(i in 1:ns) {
			for(k in 1:nresp(object)) {
			    object@response[[i]][[k]] <- fit(object@response[[i]][[k]],w=gamma[,i])
				# update dens slot of the model
				object@dens[,k,i] <- dens(object@response[[i]][[k]])
			}
		}
		
		# initial expectation
		fbo <- fb(init=object@init,matrix(0,1,1),B=object@dens,ntimes=ntimes(object))
		LL <- fbo$logLike
		
		if(is.nan(LL)) stop("Cannot find suitable starting values; please provide them.")
		
	} else {
		# initial expectation
		fbo <- fb(init=object@init,A=matrix(0,1,1),B=object@dens,ntimes=ntimes(object))
		LL <- fbo$logLike
		if(is.nan(LL)) stop("Starting values not feasible; please provide them.")
		
		#B <- apply(object@dens,c(1,3),prod)
		#gamma <- object@init*B
		#LL <- sum(log(rowSums(gamma)))
		#if(is.nan(LL)) stop("Starting values not feasible; please provide them.")
		#gamma <- gamma/rowSums(gamma)
	}
	
	LL.old <- LL + 1
	
	while(j <= maxit & !converge) {
		
		# maximization
		
		# should become object@prior <- fit(object@prior)
		
		if(clsf == "hard") {
		    fbo$gamma <- t(apply(gamma,1,ind.max))
		}
		object@prior@y <- fbo$gamma[bt,,drop=FALSE]
		object@prior <- fit(object@prior, w=NULL,ntimes=NULL)
		object@init <- dens(object@prior)
		
		for(i in 1:ns) {
			for(k in 1:nresp(object)) {
				object@response[[i]][[k]] <- fit(object@response[[i]][[k]],w=fbo$gamma[,i])
				# update dens slot of the model
				object@dens[,k,i] <- dens(object@response[[i]][[k]])
			}
		}
		
		# expectation
		fbo <- fb(init=object@init,A=matrix(0,1,1),B=object@dens,ntimes=ntimes(object))
		LL <- fbo$logLike
		
		#B <- apply(object@dens,c(1,3),prod)
		#gamma <- object@init*B
		#LL <- sum(log(rowSums(gamma)))

		# normalize
		#gamma <- gamma/rowSums(gamma)
		
		# print stuff
		if(verbose&((j%%5)==0)) {
			cat("iteration",j,"logLik:",LL,"\n")
		}
		
		if(LL >= LL.old) {
		  if((crit == "absolute" &&  LL - LL.old < tol) || (crit == "relative" && (LL - LL.old)/abs(LL.old)  < tol)) {
			  cat("iteration",j,"logLik:",LL,"\n")
			  converge <- TRUE
			}
		} else {
			# this should not really happen...
			if(j > 0 && (LL.old - LL) > tol) warning("likelihood decreased on iteration ",j)
		}

		LL.old <- LL
		j <- j+1

	}

	class(object) <- "mix.fitted"

	if(converge) {
		object@message <- switch(crit,
			relative = "Log likelihood converged to within tol. (relative change)",
			absolute = "Log likelihood converged to within tol. (absolute change)"
		)
	} else object@message <- "'maxit' iterations reached in EM without convergence."

	# no constraints in EM, except for the standard constraints ...
	# which are produced by the following (only necessary for getting df right in logLik and such)
	constraints <- getConstraints(object)
	object@conMat <- constraints$lincon
	object@lin.lower <- constraints$lin.l
	object@lin.upper <- constraints$lin.u
	
	object
	
}

# em for hidden markov models
em.depmix <- function(object,maxit=100,tol=1e-8,crit="relative",random.start=TRUE,verbose=FALSE, classification=c("soft","hard"),...) {
	
	if(!is(object,"depmix")) stop("object is not of class 'depmix'")
	
	clsf <- match.arg(classification)
	
	clsf="soft"
	
	ns <- nstates(object)
	
	ntimes <- ntimes(object)
	lt <- length(ntimes)
	et <- cumsum(ntimes)
	bt <- c(1,et[-lt]+1)
	
	converge <- FALSE
	j <- 0
	
	if(random.start) {
				
		nr <- sum(ntimes(object))
		#gamma <- matrix(runif(nr*ns,min=.0001,max=.9999),nrow=nr,ncol=ns)
		#gamma <- gamma/rowSums(gamma)
		gamma <- rdirichlet(nr,alpha=rep(.01,ns))
		if(clsf == "hard") {
		    gamma <- t(apply(gamma,1,ind.max))
		}
		LL <- -1e10
		
		for(i in 1:ns) {
			for(k in 1:nresp(object)) {
				object@response[[i]][[k]] <- fit(object@response[[i]][[k]],w=gamma[,i])
				# update dens slot of the model
				object@dens[,k,i] <- dens(object@response[[i]][[k]])
			}
		}
		
		# initial expectation
		fbo <- fb(init=object@init,A=object@trDens,B=object@dens,ntimes=ntimes(object),stationary=object@stationary)
		LL <- fbo$logLike
		
		if(is.nan(LL)) stop("Cannot find suitable starting values; please provide them.")
		
	} else {
		# initial expectation
		fbo <- fb(init=object@init,A=object@trDens,B=object@dens,ntimes=ntimes(object),stationary=object@stationary)
		LL <- fbo$logLike
		if(is.nan(LL)) stop("Starting values not feasible; please provide them.")
	}
	
	LL.old <- LL + 1
	
	while(j <= maxit & !converge) {
		
		# maximization
				
		# should become object@prior <- fit(object@prior, gamma)
		object@prior@y <- fbo$gamma[bt,,drop=FALSE]
		object@prior <- fit(object@prior, w=NULL, ntimes=NULL)
		object@init <- dens(object@prior)
				
		trm <- matrix(0,ns,ns)
		for(i in 1:ns) {
			if(!object@stationary) {
				object@transition[[i]]@y <- fbo$xi[,,i]/fbo$gamma[,i]
				object@transition[[i]] <- fit(object@transition[[i]],w=as.matrix(fbo$gamma[,i]),ntimes=ntimes(object)) # check this
			} else {
				for(k in 1:ns) {
					trm[i,k] <- sum(fbo$xi[-c(et),k,i])/sum(fbo$gamma[-c(et),i])
				}
				# FIX THIS; it will only work with specific trinModels
				# should become object@transition = fit(object@transition, xi, gamma)
				object@transition[[i]]@parameters$coefficients <- switch(object@transition[[i]]@family$link,
					identity = object@transition[[i]]@family$linkfun(trm[i,]),
					mlogit = object@transition[[i]]@family$linkfun(trm[i,],base=object@transition[[i]]@family$base),
					object@transition[[i]]@family$linkfun(trm[i,])
				)
			}
			# update trDens slot of the model
			object@trDens[,,i] <- dens(object@transition[[i]])
		}
		
		for(i in 1:ns) {
			for(k in 1:nresp(object)) {
				object@response[[i]][[k]] <- fit(object@response[[i]][[k]],w=fbo$gamma[,i])
				# update dens slot of the model
				object@dens[,k,i] <- dens(object@response[[i]][[k]])
			}
		}
		
		# expectation
		fbo <- fb(init=object@init,A=object@trDens,B=object@dens,ntimes=ntimes(object),stationary=object@stationary)
		LL <- fbo$logLike
				
		if(verbose&((j%%5)==0)) cat("iteration",j,"logLik:",LL,"\n")
		
		if( (LL >= LL.old)) {
		  if((crit == "absolute" &&  LL - LL.old < tol) || (crit == "relative" && (LL - LL.old)/abs(LL.old)  < tol)) {
			  cat("iteration",j,"logLik:",LL,"\n")
			  converge <- TRUE
			}
		} else {
		  # this should not really happen...
			if(j > 0 && (LL.old - LL) > tol) warning("likelihood decreased on iteration ",j)
		}
		
		LL.old <- LL
		j <- j+1
		
	}
		
	class(object) <- "depmix.fitted"
	
	if(converge) {
		object@message <- switch(crit,
			relative = "Log likelihood converged to within tol. (relative change)",
			absolute = "Log likelihood converged to within tol. (absolute change)"
		)
	} else object@message <- "'maxit' iterations reached in EM without convergence."
	
	# no constraints in EM, except for the standard constraints ...
	# which are produced by the following (only necessary for getting df right in logLik and such)
	constraints <- getConstraints(object)
	object@conMat <- constraints$lincon
	object@lin.lower <- constraints$lin.l
	object@lin.upper <- constraints$lin.u
	
	object
}
