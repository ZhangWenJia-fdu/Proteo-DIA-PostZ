args <- commandArgs(trailingOnly = FALSE)
trailing <- commandArgs(trailingOnly = TRUE)
install_missing <- '--install-missing' %in% trailing
file_arg <- grep('^--file=', args, value = TRUE)
root <- if (length(file_arg) > 0) {
  dirname(normalizePath(sub('^--file=', '', file_arg[1]), winslash = '/', mustWork = TRUE))
} else {
  getwd()
}

portable_lib <- file.path(root, 'portable', 'Rlibs')
dir.create(portable_lib, recursive = TRUE, showWarnings = FALSE)
Sys.setenv(R_LIBS_USER = portable_lib)
.libPaths(unique(c(portable_lib, file.path(R.home('home'), 'library'))))

log_dir <- file.path(root, 'logs')
dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)
log_file <- file.path(log_dir, 'dependency_check.log')
install_log_file <- file.path(log_dir, 'dependency_install.log')
write_log <- function(...) {
  cat(format(Sys.time(), '%Y-%m-%d %H:%M:%S'), ' ', paste(..., collapse = ''), '\n', file = log_file, append = TRUE, sep = '')
}
write_install_log <- function(...) {
  cat(format(Sys.time(), '%Y-%m-%d %H:%M:%S'), ' ', paste(..., collapse = ''), '\n', file = install_log_file, append = TRUE, sep = '')
}

core_file <- file.path(root, 'app', 'R', 'analysis_core.R')
if (!file.exists(core_file)) {
  msg <- paste0('Cannot find dependency manifest: ', core_file)
  write_log(msg)
  cat(msg, '\n', sep = '')
  quit(status = 10, save = 'no')
}

source(core_file, encoding = 'UTF-8')
if (!exists('dependency_manifest')) {
  msg <- 'Dependency manifest is not defined in app/R/analysis_core.R.'
  write_log(msg)
  cat(msg, '\n', sep = '')
  quit(status = 11, save = 'no')
}

cran_packages <- unique(dependency_manifest$cran_runtime)
bioc_packages <- unique(dependency_manifest$bioconductor_runtime)
r_base_packages <- unique(dependency_manifest$r_base_runtime)
runtime_packages <- unique(c(cran_packages, bioc_packages, r_base_packages))
missing <- runtime_packages[!vapply(runtime_packages, requireNamespace, logical(1), quietly = TRUE)]
missing_cran <- intersect(missing, cran_packages)
missing_bioc <- intersect(missing, bioc_packages)
missing_base <- intersect(missing, r_base_packages)

if (length(missing) == 0) {
  write_log('Dependency check passed. Library paths: ', paste(.libPaths(), collapse = '; '))
  cat('DEPENDENCY_CHECK_OK\n')
  quit(status = 0, save = 'no')
}

write_log('Missing R packages: ', paste(missing, collapse = ', '))
if (length(missing_base) > 0) {
  write_log('Base R packages missing and not suitable for automatic installation: ', paste(missing_base, collapse = ', '))
}

if (!install_missing) {
  cat('MISSING_PACKAGES:', paste(missing, collapse = ','), '\n', sep = '')
  if (length(missing_cran) > 0) cat('MISSING_CRAN:', paste(missing_cran, collapse = ','), '\n', sep = '')
  if (length(missing_bioc) > 0) cat('MISSING_BIOC:', paste(missing_bioc, collapse = ','), '\n', sep = '')
  if (length(missing_base) > 0) cat('MISSING_SYSTEM:', paste(missing_base, collapse = ','), '\n', sep = '')
  quit(status = 20, save = 'no')
}

write_install_log('User confirmed installation for missing packages: ', paste(missing, collapse = ', '))
write_install_log('Target library: ', portable_lib)
if (length(missing_base) > 0) {
  write_install_log('Cannot auto-install base/system packages: ', paste(missing_base, collapse = ', '))
  cat('INSTALL_FAILED: base/system packages cannot be installed automatically: ', paste(missing_base, collapse = ', '), '\n', sep = '')
  quit(status = 30, save = 'no')
}

if (length(missing_cran) > 0) {
  write_install_log('Installing CRAN packages: ', paste(missing_cran, collapse = ', '))
  tryCatch(
    install.packages(missing_cran, lib = portable_lib, repos = 'https://cloud.r-project.org', dependencies = TRUE),
    error = function(e) {
      write_install_log('CRAN installation failed: ', conditionMessage(e))
      cat('INSTALL_FAILED:', conditionMessage(e), '\n', sep = '')
      quit(status = 31, save = 'no')
    }
  )
}

if (length(missing_bioc) > 0) {
  if (!requireNamespace('BiocManager', quietly = TRUE)) {
    write_install_log('Installing CRAN package BiocManager for Bioconductor installation')
    tryCatch(
      install.packages('BiocManager', lib = portable_lib, repos = 'https://cloud.r-project.org', dependencies = TRUE),
      error = function(e) {
        write_install_log('BiocManager installation failed: ', conditionMessage(e))
        cat('INSTALL_FAILED:', conditionMessage(e), '\n', sep = '')
        quit(status = 32, save = 'no')
      }
    )
  }
  write_install_log('Installing Bioconductor packages: ', paste(missing_bioc, collapse = ', '))
  tryCatch(
    BiocManager::install(missing_bioc, lib = portable_lib, ask = FALSE, update = FALSE),
    error = function(e) {
      write_install_log('Bioconductor installation failed: ', conditionMessage(e))
      cat('INSTALL_FAILED:', conditionMessage(e), '\n', sep = '')
      quit(status = 33, save = 'no')
    }
  )
}

missing_after <- runtime_packages[!vapply(runtime_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_after) > 0) {
  write_install_log('Packages still missing after installation: ', paste(missing_after, collapse = ', '))
  cat('INSTALL_FAILED: packages still missing after installation: ', paste(missing_after, collapse = ', '), '\n', sep = '')
  quit(status = 34, save = 'no')
}

write_install_log('Dependency installation completed successfully.')
write_log('Dependency check passed after installation. Library paths: ', paste(.libPaths(), collapse = '; '))
cat('INSTALL_OK\n')
quit(status = 0, save = 'no')