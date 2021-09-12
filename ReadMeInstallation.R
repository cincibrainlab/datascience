################################################################################
#  ACADEMIC SITE  =============================================================#

# ==== GUIDES =================================================================#
# https://alison.rbind.io/blog/2020-12-new-year-new-blogdown/
# https://shilaan.rbind.io/post/building-your-website-using-r-blogdown/

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

# ==== SETUP  =====================================================#
serve_site()
blogdown::check_content()
blogdown::check_site()
rstudioapi::navigateToFile("config/_default/menus.toml")
rstudioapi::navigateToFile("config.yaml", line = 15)
rstudioapi::navigateToFile("content/authors/admin/_index.md")

# ==== ADD NEW BLOG POST  =====================================================#
blogdown::new_post(title = "newpost", 
                   ext = '.Rmarkdown', 
                   subdir = "post")

