suppressPackageStartupMessages({
  library(data.table)
  library(httr)
  library(Peptides)
})

args <- commandArgs(trailingOnly = TRUE)
organism_id <- if (length(args) >= 1) args[1] else "9606"
reviewed <- if (length(args) >= 3) as.logical(args[3]) else TRUE
species_labels <- c("9606" = "human", "10090" = "mouse", "6239" = "celegans")
species_label <- if (organism_id %in% names(species_labels)) species_labels[[organism_id]] else paste0("taxid", organism_id)
scope_label <- if (isTRUE(reviewed)) "reviewed" else "all"
out_file <- if (length(args) >= 2) args[2] else file.path("app", "annotations", sprintf("uniprot_%s_%s_%s_annotations.csv", scope_label, species_label, organism_id))

clean_seq <- function(seq) {
  seq <- toupper(as.character(seq))
  seq <- gsub("[^ACDEFGHIKLMNPQRSTVWY]", "", seq)
  ifelse(nchar(seq) > 0, seq, NA_character_)
}
safe_num <- function(expr) tryCatch(expr, error = function(e) NA_real_)
count_tm <- function(x) {
  if (is.na(x) || trimws(x) == "") return(0L)
  n <- gregexpr("TRANSMEM", x, ignore.case = TRUE)[[1]]
  if (n[1] > 0) return(length(n))
  n2 <- gregexpr("[0-9]+\\.\\.[0-9]+", x)[[1]]
  if (n2[1] > 0) return(length(n2))
  1L
}
subcell_class <- function(txt, tm) {
  txt <- tolower(ifelse(is.na(txt), "", txt))
  if (grepl("mitochond", txt)) return("Mitochondria")
  if (grepl("nucleus|nuclear|nucleolus", txt)) return("Nucleus")
  if (grepl("cytoplasm|cytosol", txt)) return("Cytoplasm")
  if (grepl("membrane", txt) || (!is.na(tm) && tm > 0)) return("Membrane")
  "Other/Unknown"
}

next_link <- function(headers) {
  link <- headers[["link"]]
  if (is.null(link)) link <- headers[["Link"]]
  if (is.null(link) || !grepl("rel=\"next\"", link)) return(NULL)
  m <- regexec("<([^>]+)>; rel=\"next\"", link)
  hit <- regmatches(link, m)[[1]]
  if (length(hit) < 2) return(NULL)
  hit[2]
}
query <- paste0("taxonomy_id:", organism_id)
if (isTRUE(reviewed)) query <- paste0(query, " AND reviewed:true")
base <- "https://rest.uniprot.org/uniprotkb/search"
params <- list(
  query = query,
  format = "tsv",
  fields = "accession,id,protein_name,sequence,cc_subcellular_location,ft_transmem",
  size = 500
)
message("Fetching UniProt annotations for organism ", organism_id, " reviewed=", reviewed)
url <- modify_url(base, query = params)
chunks <- list()
page <- 0L
repeat {
  page <- page + 1L
  res <- RETRY("GET", url, times = 4, pause_min = 1, pause_cap = 8, timeout(240))
  stop_for_status(res)
  txt <- content(res, as = "text", encoding = "UTF-8")
  if (!nzchar(txt)) break
  dat <- fread(text = txt, data.table = FALSE)
  if (nrow(dat) > 0) chunks[[length(chunks) + 1L]] <- dat
  message("Fetched page ", page, ": ", nrow(dat), " rows")
  url <- next_link(headers(res))
  if (is.null(url)) break
}
raw <- if (length(chunks) > 0) rbindlist(chunks, use.names = TRUE, fill = TRUE) |> as.data.frame() else data.frame()
if (nrow(raw) == 0) stop("No UniProt rows returned for organism_id=", organism_id)
setnames(raw, old = names(raw), new = make.names(names(raw)), skip_absent = TRUE)
first_col <- function(pattern) { x <- grep(pattern, names(raw), ignore.case = TRUE, value = TRUE); if (length(x) == 0) NA_character_ else x[1] }
acc_col <- first_col("^Entry$"); id_col <- first_col("Entry.Name"); pn_col <- first_col("Protein.names"); seq_col <- first_col("^Sequence$"); sl_col <- first_col("Subcellular.location"); tm_col <- first_col("Transmembrane")
getv <- function(col) if (is.na(col)) rep(NA_character_, nrow(raw)) else as.character(raw[[col]])
seqs <- clean_seq(getv(seq_col)); tm <- vapply(getv(tm_col), count_tm, integer(1))
out <- data.frame(
  Accession = getv(acc_col), EntryName = getv(id_col), ProteinNames = getv(pn_col), Sequence = seqs,
  SubcellularLocation = getv(sl_col), Transmembrane = getv(tm_col),
  GRAVY = vapply(seqs, function(s) if (is.na(s)) NA_real_ else safe_num(Peptides::hydrophobicity(s, scale = "KyteDoolittle")), numeric(1)),
  TM_helices = tm, Subcellular_class = mapply(subcell_class, getv(sl_col), tm),
  MW = vapply(seqs, function(s) if (is.na(s)) NA_real_ else safe_num(Peptides::mw(s, monoisotopic = FALSE)), numeric(1)),
  pI = vapply(seqs, function(s) if (is.na(s)) NA_real_ else safe_num(Peptides::pI(s, pKscale = "EMBOSS")), numeric(1)),
  Length = nchar(seqs), OrganismID = organism_id, ReviewedOnly = reviewed, BuildDate = as.character(Sys.Date()),
  stringsAsFactors = FALSE
)
out <- unique(out[!is.na(out$Accession) & out$Accession != "", ])
dir.create(dirname(out_file), recursive = TRUE, showWarnings = FALSE)
fwrite(out, out_file)
message("Wrote ", nrow(out), " rows to ", out_file)