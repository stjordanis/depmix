\name{depmixS4-package}

\alias{depmixS4}
\alias{depmixS4-package}

\docType{package}

\title{

depmixS4 provides classes for specifying and fitting hidden Markov models

}

\description{

	\code{depmixS4} is a framework for specifying and fitting dependent
	mixture models, otherwise known as hidden or latent Markov models.
	Optimization is done with the EM algorithm or optionally with Rdonlp2
	when (general linear (in-)equality) constraints on the parameters need
	to be incorporated.  Models can be fitted on (multiple) sets of
	observations.  The response densities for each state may be chosen from
	the GLM family, or a multinomial.  User defined response densities are
	easy to add.
	
	Mixture or latent class (regression) models can also be fitted; these
	are the limit case in which the length of observed time series is 1 for
	all cases. 

}

\details{

	\tabular{ll}{
		Package: \tab depmixS4\cr
		Type: \tab Package\cr
		Version: \tab 0.2-2\cr
		Date: \tab 2009-13-05\cr
		License: \tab GPL\cr
	}

	Model fitting is done in two steps; first, models are specified through
	the \code{\link{depmix}} function (or the \code{\link{mix}} function for
	mixture and latent class models), which both use standard
	\code{\link{glm}} style arguments to specify the observed
	distributions; second, the model needs to be fitted by using the
	\code{\link{fit}} function; imposing constraints is done through the
	fit function.  Standard output includes the optimized parameters and
	the posterior densities for the states and the optimal state sequence.

}

\author{

Ingmar Visser & Maarten Speekenbrink

Maintainer: i.visser@uva.nl

}

\references{

	On hidden Markov models: Lawrence R. Rabiner (1989).  A tutorial on
	hidden Markov models and selected applications in speech recognition.
	\emph{Proceedings of IEEE}, 77-2, p.  267-295.

	On latent class models: A. L. McCutcheon (1987).  \emph{Latent class
	analysis}.  Sage Publications.

}

\keyword{ package }

\seealso{

	\code{\link{depmix}}, \code{\link{fit}}

}

\examples{
	# These should be added at some point ...
}