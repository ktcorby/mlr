#' @export
makeRLearner.regr.rq = function() {
  makeRLearnerRegr(
    cl = "regr.rq",
    package = "quantreg",
    par.set = makeParamSet(
      makeUntypedLearnerParam(id = "tau", default = 0.5),
      makeDiscreteLearnerParam(id = "method", default = "br",
                               values=c("br", "fn", "pfn", "sfn", "fnc", "lasso", "scad"),
                               tunable = TRUE)
    ),
    properties = c("numerics", "factors", "quantiles"),
    name = "Quantile Regression",
    short.name = "rq",
    note = ""
  )
}

#' @export
trainLearner.regr.rq = function(.learner, .task, .subset, .weights = NULL,
                                tau = 0.5, method = "br",
                                ...) {
  f = getTaskFormula(.task)
  m = quantreg::rq(f, data = getTaskData(.task, .subset),
                   tau = tau, method = method, ...)
  return(list(m = m, tau = tau))
}

#' @export
predictLearner.regr.rq = function(.learner, .model, .newdata, ...) {
  rv = predict(.model$learner.model$m, newdata = .newdata) #, ...)
  if (.learner$predict.type == "response") {
    if (length(dim(rv)) == 2) {
      # convert quantiles to reponse by computing expected value
      # probably really only works well if quantiles
      # are dense and uniform
      rv = apply(rv, 1, function(r) {
        dns = density(r, bw="SJ")
        return(sum(dns$y*dns$x) / sum(dns$y))
      })
    }
    else {
      return(rv)
    }
  }
  else if (.learner$predict.type == "quantiles") {
    return(rv)
  }
}

