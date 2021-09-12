---
title: "Reproducible academic manuscripts using GNU Make: Part 2"
author: Ernie Pedapati
date: '2021-09-11'
slug: newpost
categories: []
tags: []
subtitle: ''
summary: ''
authors: []
lastmod: '2021-09-11T23:00:17-04:00'
featured: no
image:
  caption: ''
  focal_point: Smart
  preview_only: no
projects: []
---
### Hands-on with Make!
In the last post, we introduced Make as an automated way to create assets from source files. The most important coding concept was to make sure each script had clearly defined inputs and outputs. You see, Make doesn't care what application you might use, it only keeps tracks of filenames and the date/time in which they are saved.

In this tutorial, we are going to do hands-on programming with Make. We are going to use a minimal and reproducible example. If you are an experienced programmer, this might be all you need to start using Makefiles for the creation of publications. On the other hand, if you want to start using Make with minimal customization, in part 3, we will demonstrate how to use our Makefile templates to easily transition your current code.

### Installing Make and configuring paths

Make is an open source multi-platform software released and maintained by GNU Project (https://www.gnu.org/software/make/). On Linux and Mac, the Make application is likely already installed and can be accessed by a Terminal. 



