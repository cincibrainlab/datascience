# First Time Install
# Instructions
# https://alison.rbind.io/blog/2020-12-new-year-new-blogdown/
# https://shilaan.rbind.io/post/building-your-website-using-r-blogdown/#website-icon

# configure GITHUB
# https://happygitwithr.com/credential-caching.html#credential-caching
library(gitcreds)
gitcreds_set() # made in github
# Restart R

# Install BlogDown
if (!requireNamespace("remotes")) install.packages("remotes")
remotes::install_github("rstudio/blogdown")
blogdown::install_hugo("0.84.4")

library(blogdown)

# Initial configuration of profiles
blogdown::config_Rprofile() 
blogdown::config_netlify()

# Only for starting new sites
# new_site(theme = "wowchemy/starter-academic")
# blogdown::new_post(title = "Hi Hugo", 
#                    ext = '.Rmarkdown', 
#                    subdir = "post")
# Add to options: 
# options(
#   # to automatically serve the site on RStudio startup, set this option to TRUE
#   blogdown.serve_site.startup = FALSE,
#   # to disable knitting Rmd files on save, set this option to FALSE
#   blogdown.knit.on_save = FALSE     <- change
#   blogdown.author = "Alison Hill",  <- add
#   blogdown.ext = ".Rmarkdown",      <- add
#   blogdown.subdir = "post"          <- add
# )
# Check gitignore
# file.edit(".gitignore")
# blogdown::check_gitignore()

serve_site()
blogdown::check_content()

rstudioapi::navigateToFile("config/_default/menus.toml")
rstudioapi::navigateToFile("config.yaml", line = 15)
rstudioapi::navigateToFile("content/authors/admin/_index.md")

blogdown::edit_draft(c(
  "content/privacy.md",
  "content/terms.md"
)) 

# Change username in Bash
# git config --global user.name "ernest.pedapati@cchmc.org"
# git config --global user.name


blogdown::new_post(title = "Using GNU Make for Reproducible R Research", 
                   ext = '.Rmarkdown', 
                   subdir = "post")
