# 
# Ingmar Visser
# 
# FORWARD-BACKWARD function, user interface, 10-06-2008
# 

setMethod("forwardbackward","depmix",
	function(object, return.all=TRUE, ...) {
		fb(init=object@init,A=object@trDens,B=object@dens,ntimes=ntimes(object), 
			stationary=object@stationary,return.all=return.all)
	}
)



