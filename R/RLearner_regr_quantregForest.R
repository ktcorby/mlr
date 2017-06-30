#' @export
makeRLearner.regr.quantregForest = function() {
  makeRLearnerRegr(
    cl = "regr.quantregForest",
    package = "quantregForest",
    par.set = makeParamSet(
      makeUntypedLearnerParam("tau", default = 0.5),
      # the rest are just copied from randomForest regr and we will
      # pass them on. Haven't tested that all work
      makeIntegerLearnerParam(id = "ntree", default = 500L, lower = 1L),
      makeIntegerLearnerParam(id = "mtry", lower = 1L),
      makeLogicalLearnerParam(id = "replace", default = TRUE),
      makeUntypedLearnerParam(id = "strata", tunable = FALSE),
      makeIntegerVectorLearnerParam(id = "sampsize", lower = 1L),
      makeIntegerLearnerParam(id = "nodesize", default = 5L, lower = 1L),
      makeIntegerLearnerParam(id = "maxnodes", lower = 1L),
      makeLogicalLearnerParam(id = "importance", default = FALSE),
      makeLogicalLearnerParam(id = "localImp", default = FALSE),
      makeIntegerLearnerParam(id = "nPerm", default = 1L),
      makeLogicalLearnerParam(id = "proximity", default = FALSE, tunable = FALSE),
      makeLogicalLearnerParam(id = "do.trace", default = FALSE, tunable = FALSE),
      makeLogicalLearnerParam(id = "keep.forest", default = TRUE, tunable = FALSE),
      makeLogicalLearnerParam(id = "keep.inbag", default = FALSE, tunable = FALSE)
    ),
    properties = c("numerics", "factors", "quantiles"),
    name = "Quantile Regression Forests",
    short.name = "quantregForest",
    note = ""
  )
}



#' @export
trainLearner.regr.quantregForest = function(.learner, .task, .subset, .weights = NULL,
                                      tau = 0.5,
                                      ...) {
  tdata = getTaskData(.task, .subset)
  targetname = getTaskTargetNames(.task)[1]
  fnames = names(tdata)
  fnames = fnames[!(fnames %in% c(targetname))]
  xdata = tdata[,fnames]
  ydata = tdata[,targetname]
  m = quantregForest::quantregForest(xdata, ydata)
  return(list(model = m, tau = tau))
}

#' @export
predictLearner.regr.quantregForest = function(.learner, .model, .newdata, ...) {
  rv = predict(.model$learner.model$model, newdata = .newdata,
               what=.model$learner.model$tau) #, ...)
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

