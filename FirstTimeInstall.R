# First Time Install
# https://alison.rbind.io/blog/2020-12-new-year-new-blogdown/
if (!requireNamespace("remotes")) install.packages("remotes")
remotes::install_github("rstudio/blogdown")

library(blogdown)
new_site(theme = "wowchemy/starter-academic")

blogdown::new_post(title = "Hi Hugo", 
                   ext = '.Rmarkdown', 
                   subdir = "post")

blogdown::config_Rprofile() 
# 
# options(
#   # to automatically serve the site on RStudio startup, set this option to TRUE
#   blogdown.serve_site.startup = FALSE,
#   # to disable knitting Rmd files on save, set this option to FALSE
#   blogdown.knit.on_save = FALSE     <- change
#   blogdown.author = "Alison Hill",  <- add
#   blogdown.ext = ".Rmarkdown",      <- add
#   blogdown.subdir = "post"          <- add
# )

serve_site()

file.edit(".gitignore")
blogdown::check_gitignore()
blogdown::check_content()

blogdown::config_netlify()

rstudioapi::navigateToFile("config/_default/menus.toml")

rstudioapi::navigateToFile("config.yaml", line = 15)

rstudioapi::navigateToFile("content/authors/admin/_index.md")
