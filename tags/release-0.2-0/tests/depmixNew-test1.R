
# 
# Started by Ingmar Visser & Maarten Speekenbrink, 31-1-2007
# 
# Usage: go to trunk directory and source this file in R, if the program
# still works it should return TRUE at every test (or make immediate sense
# otherwise)

# Changes: 
# 
# 16-5-2007, made this a new copy with basic tests of computing the
# likelihood, copying parameters etc
# 
# Other tests with optimization of models are moved to depmix-test2.R
# 

# 
# TEST 1: speed data model with optimal parameters, compute the likelihood
# 

require(depmixS4)

data(speed)   

pars <- c(1,0.916,0.084,0.101,0.899,6.39,0.24,0.098,0.902,5.52,0.202,0.472,0.528,1,0)

rModels <- list(
	list(
		GLMresponse(formula=rt~1,data=speed,family=gaussian(),pstart=c(5.52,.202)),
		GLMresponse(formula=corr~1,data=speed,family=multinomial(),pstart=c(0.472,0.528))
	),
	list(
		GLMresponse(formula=rt~1,data=speed,family=gaussian(),pstart=c(6.39,.24)),
		GLMresponse(formula=corr~1,data=speed,family=multinomial(),pstart=c(.098,.902))
	)
)

trstart=c(0.899,0.101,0.084,0.916)

transition <- list()
transition[[1]] <- transInit(~1,nstates=2,data=data.frame(1),pstart=c(trstart[1:2]))
transition[[2]] <- transInit(~1,nstates=2,data=data.frame(1),pstart=c(trstart[3:4]))

instart=c(0,1)
inMod <- transInit(~1,ns=2,ps=instart,data=data.frame(rep(1,3)))

mod <- makeDepmix(response=rModels,transition=transition,prior=inMod,ntimes=attr(speed,"ntimes"))

ll <- logLik(mod)
ll.fb <- logLik(mod,method="fb")

logl <- -296.115107102 # see above

cat("Test 1: ", all.equal(c(ll),logl,check.att=FALSE), "(loglike of speed data) \n")


# 
# model specification made easy
# 

library(depmixS4)

resp <- c(5.52,0.202,0.472,0.528,6.39,0.24,0.098,0.902)
trstart=c(0.899,0.101,0.084,0.916)
instart=c(0,1)
mod <- depmix(list(rt~1,corr~1),data=speed,nstates=2,family=list(gaussian(),multinomial()),respstart=resp,trstart=trstart,instart=instart,prob=T)

ll2 <- logLik(mod)

cat("Test 1b: ", all.equal(c(ll),c(ll2),check.att=FALSE), "(loglike of speed data) \n")

# 
# TEST 2
# 
# To check the density function for the multinomial responses with a covariate
# test a model with a single state, which should be identical to a glm
# first fit a model without covariate
# 

invlogit <- function(lp) {exp(lp)/(1+exp(lp))}

acc <- glm(corr~1,data=speed,family=binomial)

p1 <- invlogit(coef(acc)[1])
p0 <- 1-p1

mod <- depmix(corr~1,data=speed,nst=1,family=multinomial(),trstart=1,instart=c(1),respstart=c(p0,p1))

ll <- logLik(mod)

dev <- -2*ll

cat("Test 2: ", all.equal(c(dev),acc$deviance),"(loglike of 1-comp glm on acc data) \n")


# 
# TEST 3
# 
# now add the covariate and compute the loglikelihood
# 

acc <- glm(corr~Pacc,data=speed,family=binomial)

p1 <- invlogit(coef(acc)[1])
p0 <- 1-p1

pstart=c(p0,p1,0,coef(acc)[2])

mod <- depmix(corr~Pacc,data=speed,family=multinomial(),trstart=1,instart=1,respst=pstart,nstate=1)

ll <- logLik(mod)
dev <- -2*ll

cat("Test 3: ", all.equal(c(dev),acc$deviance),"(same but now with covariate) \n")

# 
# 2-state model with covariate
# 

trstart=c(0.896,0.104,0.084,0.916)
trstart=c(trstart[1:2],0,0.01,trstart[3:4],0,0.01)
instart=c(0,1)
resp <- c(5.52,0.202,0.472,0.528,6.39,0.24,0.098,0.902)

mod <- depmix(list(rt~1,corr~1),data=speed,family=list(gaussian(),multinomial()),transition=~Pacc,trstart=trstart,instart=instart,respst=resp,nst=2)
ll <- logLik(mod)

cat("Test 4: ll is now larger than speedll, ie ll is better due to introduction of a covariate \n")
cat("Test 4: ", ll,"\t", logl, "\n")
cat("Test 4: ", ll > logl, "\n")


# 
# test getpars and setpars
# 

trstart=c(0.896,0.104,0.084,0.916)
trstart=c(trstart[1:2],0,0.01,trstart[3:4],0,0.01)
instart=c(0,1)
resp <- c(5.52,0.202,0.472,0.528,6.39,0.24,0.098,0.902)

mod <- depmix(list(rt~1,corr~1),data=speed,family=list(gaussian(),multinomial()),transition=~Pacc,trstart=trstart,instart=instart,respst=resp,nst=2)

mod1 <- setpars(mod,getpars(mod))

cat("Test 5: ", all.equal(getpars(mod),getpars(mod1)), "(getpars and setpars) \n")





