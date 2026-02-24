library(tibble)
library(htmltools)
library(dplyr)
library(tidyr)

make_williams_products <- function(
    products_tbl = tibble(                        # tibble with product_id (image filename), product_name, product_desc
      product_id   = c("SOY_LIQ", "DAIRY_LIQ", "SOY_SEMI", "DAIRY_SEMI", "SOY_SOLID", "DAIRY_SOLID"),  # unique image filename for each product
      product_name = c("Soy milk", "Cow's milk", "Douhua", "Yoghurt from cow's milk", "Yuba (tofu skin)", "Cheese from cow's milk"),
      product_desc = c(
        "This product is a liquid, soy-based food product made from soybeans. It has a uniform, liquid consistency and can be poured and drunk. The product is typically consumed cold or at room temperature.",
        "This product is a liquid, dairy-based food product made from cow's milk. It has a uniform, liquid consistency and can be poured and drunk. The product is typically consumed cold or at room temperature.",
        "This product is a soft, firm, soy-based food product made from coagulated soymilk. It has a soft, firm consistency that holds its shape but can be easily divided with a spoon. The product is typically consumed cold or warm.",
        "This product is a creamy, dairy-based food product made from fermented cow's milk. It has a creamy consistency and can be eaten with a spoon. The product is typically consumed cold.",
        "This product is a rubbery, firm, soy-based food product made from coagulated soy milk. It has a rubbery, firm consistency that holds its shape, and are easy to chew. The product is typically consumed warm.",
        "This product is a firm dairy-based food product made from cow's milk. Often known as cheese for pizza. When heated it has a smooth, creamy to chewy, elastic consistency. The product is typically consumed warm or at room temperature."
      )
    ),
    n_ids             = 500,      # number of participant IDs to generate
    id_name           = "ID",     # name of the participant ID column in the output
    product_name_size = "1.5em",  # CSS font-size for the product name in the HTML output
    product_desc_size = "1.1em",  # CSS font-size for the product description in the HTML output
    output_file       = "wd.csv"  # file path for the output CSV (set NULL to skip writing)
) {
  
  if (!requireNamespace("crossdes", quietly = TRUE)) stop("Package 'crossdes' is required.")
  if (!all(c("product_id", "product_name", "product_desc") %in% names(products_tbl))) {
    stop("products_tbl must contain product_id, product_name, and product_desc")
  }
  
  products_tbl <- products_tbl %>%
    mutate(product_html = paste0(
      "<span style='font-size: ", product_name_size, ";'><strong>", product_name, "</strong></span><br><br>",
      "<span style='font-size: ", product_desc_size, ";'>", product_desc, "</span>"
    ))
  
  product_ids <- as.character(products_tbl$product_id)
  k           <- length(product_ids)
  wd          <- crossdes::williams(k)
  wd_named    <- matrix(product_ids[wd], nrow = nrow(wd), ncol = ncol(wd))
  out         <- as.data.frame(wd_named, stringsAsFactors = FALSE)
  idx         <- rep(seq_len(nrow(out)), length.out = n_ids)
  out         <- out[idx, , drop = FALSE]
  out[[id_name]] <- seq_len(nrow(out))
  out         <- out[, c(id_name, setdiff(names(out), id_name))]
  colnames(out) <- c(id_name, paste0("sample", seq_len(ncol(out) - 1)))
  rownames(out) <- NULL
  
  sample_cols <- grep("^sample\\d+$", names(out), value = TRUE)
  
  result <- out %>%
    pivot_longer(all_of(sample_cols), names_to = "sample_pos", values_to = "product_id") %>%
    left_join(products_tbl, by = "product_id") %>%
    pivot_wider(
      id_cols     = all_of(id_name),
      names_from  = sample_pos,
      values_from = c(product_id, product_html),
      names_glue  = "{sample_pos}{ifelse(.value == 'product_html', '_desc', '')}"
    )
  
  if (!is.null(output_file)) {
    write.csv(result, output_file, row.names = FALSE)
    message("Design written to: ", output_file)
  }
  
  invisible(result)
}

# Run with zero arguments — everything uses defaults
make_williams_products()
