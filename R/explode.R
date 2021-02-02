
#' Print the Output of Intermediate Steps of a Call
#'
#' @param expr call to explode
#'
#' @export
#'
#' @examples
#' boom(subset(head(mtcars, 2), qsec > 17))
boom <- function(expr) {
  # if we are in a pipe chain, explode the chain above
  scs <- sys.calls()
  l <- length(scs)
  call_is_piped <-
    identical(scs[[l]][[2]], quote(.)) &&
    identical(scs[[l-1]][[1]], quote(`%>%`))
  if(call_is_piped) {
    call <- do.call(substitute, list(scs[[l]], list(. = scs[[l-1]][[2]])))
    eval.parent(call)
  }
  pf <- parent.frame()
  expr <- substitute(expr)
  funs <- setdiff(all.names(expr), c(all.vars(expr), "::", ":::"))
  wrapped <- list()
  for (fun in funs) {
    # fun will include namespaces, so we don't want to fail here if the object
    # doesn't exist
    if(!exists(fun, pf)) next
    fun_env <- environment(get(fun, envir = pf))
    # primitives don't have an environment, but they're in the base package
    if(is.null(fun_env)) {
      namespace <- "base"
    } else {
      namespace <- getNamespaceName(fun_env)
    }

    fun_val <- getExportedValue(namespace, fun)
    f <- as.function(c(alist(...=), bquote({
      sc  <- sys.call()
      sc_bkp <- sc
      sc[[1]] <- .(fun_val)
      res <- eval.parent(sc)
      writeLines(crayon::cyan(deparse(sc_bkp)))
      print(res)
    })))
    environment(f) <- asNamespace(namespace)
    wrapped[[fun]] <- f
  }
  wrapped$`::` <- function(pkg, name) {
    pkg <- as.character(substitute(pkg))
    name <- as.character(substitute(name))
    fun <- getExportedValue(pkg, name)
    as.function(c(alist(...=), bquote({
      sc  <- sys.call()
      sc_bkp <- sc
      sc[[1]] <- .(fun)
      res <- eval.parent(sc)
      writeLines(crayon::cyan(deparse(sc_bkp)))
      print(res)
    })))
  }
  wrapped$`:::` <- function(pkg, name) {
    pkg <- as.character(substitute(pkg))
    name <- as.character(substitute(name))
    fun <- get(name, envir = asNamespace(pkg), inherits = FALSE)
    as.function(c(alist(...=), bquote({
      sc  <- sys.call()
      sc_bkp <- sc
      sc[[1]] <- .(fun)
      res <- eval.parent(sc)
      writeLines(crayon::cyan(deparse(sc_bkp)))
      print(res)
    })))
  }
  environment(wrapped$`::`) <- asNamespace("base")
  environment(wrapped$`:::`) <- asNamespace("base")
  invisible(eval(expr, envir = wrapped, enclos = parent.frame()))
}
