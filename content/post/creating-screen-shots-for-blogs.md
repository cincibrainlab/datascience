---
title: Easy workflow for setting up screenshots/GIF on Blog Posts
date: 2022-03-21
draft: false
featured: false
image:
  filename: featured
  focal_point: Smart
  preview_only: false
---

# Easy workflow for setting up screenshots/GIF on Blog Posts
Writing development blogs doesn't have to be time consuming and can serve as an permanent reference the history of your workflow. I wanted to provide from tips for other data science bloggers that might overall simplify your experience.

## Note on the tools
I am going to layout a particular workflow with specific Mac OS and cloud tools. The tools we use fall into certain conceptual categories, so it should be easily adapted to your workflow.

## Tools Needed
### Screenshot utility that automatically saves to a folder
We are currently using CleanShot X, but most modern and opensource screen capture applications allow for automatic saving to a folder. 

### Cloud-based based folder with pubically sharable links
The screen capture program should share files to a cloud-based folder. The naming of the files should be unique, but do not need specific names. 

### Static-based web page generator
I do not think this last piece is a necessity, but creating webpages through Markdown text files compared to an HTML editor has been a gamechanger in terms of getting relevant posts out quickly.

### Let's see how this works in practice:
#### Screen capture utility
1. Configure your screen shot utility to automatically save captures to a cloud directory.
<img src="https://www.dropbox.com/s/05hufhsz53jbau8/CleanShot%202022-03-21%20at%2011.34.48%402x.png?raw=1" style="width:30%;">
2. Create a subdirectory within the folder to images you will link to the web. This will allow you to periodically clean your screenshot folder without breaking any posted images. 
<img src="https://www.dropbox.com/s/kyueqye60nzt15j/CleanShot%202022-03-21%20at%2011.36.51%402x.png?raw=1" style="width:30%;">

3. As you create captures, use the thumbnails/date to move images into the subfolder for staging.
<img src="https://www.dropbox.com/s/oehswdwittk0724/CleanShot%202022-03-21%20at%2011.39.58%402x.png?raw=1" style="width:30%;">

#### Cloud folder
1. When you want to use an image, generate a public link from your file and copy it to your clipboard. 
<img src="https://www.dropbox.com/s/qoxdtea7f4nf0s2/CleanShot%202022-03-21%20at%2011.42.37%402x.png?raw=1" style="width:30%;">

2. Different cloud providers may need modification of the link to work properly on a webpage. For example, Dropbox requires a change to the end of the link from "dl=1" to "raw=1". This would be an easy Find and Replace All after completing you draft. 
<img src="https://www.dropbox.com/s/jtjetprqvg3wd3o/CleanShot%202022-03-21%20at%2011.57.13%402x.png?raw=1" style="width:30%;">

#### Website
1. Save and update your webpage to your server. The captured image will be pulled from your cloud folder and displayed on the page. 
<img src="https://www.dropbox.com/s/q1q1y8lxd9j0hfs/CleanShot%202022-03-21%20at%2012.18.39%402x.png?raw=1" style="width:30%;">

## Hopefully this workflow saves some hassle when trying to add graphics to your webpage. Adding screen and animation captures can greatly enhance the accessibility of your posts!
