# Williams Design Functions for Sensory Evaluation

Two R functions for generating balanced Williams designs for sensory or consumer product evaluation studies. A Williams design ensures each product appears equally often in each position, controlling for carry-over effects across participants.

---

## Functions

### `make_williams_products()`
Generates a participant-level product sequence design with HTML-rendered product descriptions. The output is intended for use in survey tools (e.g. Qualtrics) where product names and descriptions are displayed to participants.

### `make_williams_blindingcodes()`
Generates a participant-level blinding code sequence design. The output maps each participant to a sequence of numeric blinding codes, intended for use in lab settings where samples are coded and served blind.

---

## Requirements

```r
install.packages(c("crossdes", "tibble", "dplyr", "tidyr", "htmltools"))
```

---

## Usage

Both functions run with zero arguments using built-in defaults:

```r
make_williams_products()      # writes wd.csv with product sequences + HTML descriptions
make_williams_blindingcodes() # writes wd.csv with blinding code sequences
```

Or override specific parameters as needed:

```r
make_williams_products(n_ids = 200, output_file = "product_design.csv")

make_williams_blindingcodes(
  blinding_codes = c(412, 637, 901),
  n_ids          = 150,
  output_file    = "blinding_design.csv"
)
```

---

## Output

Both functions return a wide-format data frame with one row per participant, saved to `output_file`. Set `output_file = NULL` to suppress writing.

| Column | Description |
|---|---|
| `ID` | Participant ID |
| `sample1`, `sample2`, ... | Product ID or blinding code per position |
| `sample1_desc`, ... | HTML description per position (`make_williams_products` only) |

`make_williams_blindingcodes()` additionally prints a position balance check to the console to verify the design is balanced.

---

## Notes

- If `n_ids` exceeds the number of unique Williams design rows, rows are recycled to reach the requested number of participants.
- Product images should be stored in the repository using the `product_id` values as filenames.
