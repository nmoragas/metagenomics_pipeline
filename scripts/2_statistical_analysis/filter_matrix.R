# Matrix filter
filter_matrix = function(count_matrix, relabundance_filter = 0.001, nsamples_filter = 1){
  # species in columns
  relabundance_matrix = t(apply(count_matrix, 1, function(x) {return(x/sum(x))}))
  keep = apply(relabundance_matrix, 2, function(x) {return(length(which(x > relabundance_filter)))})
  keep = names(keep[keep >= nsamples_filter])
  return(count_matrix[, keep])
}
