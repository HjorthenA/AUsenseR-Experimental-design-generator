make_williams_blindingcodes <- function(
    blinding_codes = c(859, 283, 405),  # vector of numeric blinding codes, one per product
    n_ids          = 300,               # number of participant IDs to generate
    id_name        = "ID",              # name of the participant ID column in the output
    output_file    = "wd.csv"           # file path for the output CSV (set NULL to skip writing)
) {
  
  if (!requireNamespace("crossdes", quietly = TRUE)) stop("Package 'crossdes' is required.")
  
  k <- length(blinding_codes)
  if (k < 2) stop("'blinding_codes' must contain at least 2 codes.")
  if (n_ids < 1) stop("'n_ids' must be >= 1.")
  
  wd       <- crossdes::williams(k)
  wd_named <- matrix(blinding_codes[wd], nrow = nrow(wd), ncol = ncol(wd))
  out      <- as.data.frame(wd_named, stringsAsFactors = FALSE)
  idx      <- rep(seq_len(nrow(out)), length.out = n_ids)
  out      <- out[idx, , drop = FALSE]
  out[[id_name]] <- seq_len(nrow(out))
  out      <- out[, c(id_name, setdiff(names(out), id_name))]
  colnames(out) <- c(id_name, paste0("sample", seq_len(ncol(out) - 1)))
  rownames(out) <- NULL
  
  # Print position balance check
  cat("\nSample position balance check:\n")
  sample_only    <- out[, -1, drop = FALSE]
  counts_matrix  <- sapply(sample_only, function(x) table(factor(x, levels = blinding_codes)))
  colnames(counts_matrix) <- paste0("Position", seq_len(ncol(counts_matrix)))
  print(data.frame(sample = blinding_codes, counts_matrix, row.names = NULL))
  cat("\n")
  
  if (!is.null(output_file)) {
    write.csv(out, output_file, row.names = FALSE)
    message("Design written to: ", output_file)
  }
  
  invisible(out)
}

# Run with zero arguments — everything uses defaults
make_williams_blindingcodes()
