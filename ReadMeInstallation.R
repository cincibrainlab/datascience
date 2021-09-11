################################################################################
#  ACADEMIC SITE  =============================================================#

# ==== GUIDES =================================================================#
https://alison.rbind.io/blog/2020-12-new-year-new-blogdown/
https://shilaan.rbind.io/post/building-your-website-using-r-blogdown/

# ==== GIT CREDENTIALS ========================================================#
# HELP: https://happygitwithr.com/credential-caching.html#credential-caching
library(gitcreds)
gitcreds_set()

# ==== BLOGDOWN INSTALL =======================================================#
if (!requireNamespace("remotes")) install.packages("remotes")
remotes::install_github("rstudio/blogdown")

# ==== HUGO INSTALLATIONS =====================================================#
blogdown::install_hugo("0.83.1")
blogdown::install_hugo("0.84.4")
