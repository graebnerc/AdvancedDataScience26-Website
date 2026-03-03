# Template for academic courses

When using for a new course, adjust the following:

`_publish.yml`

- The id used by Netlify (when available)
- The URL of the course website

`_quarto.yml`

- Name of the course
- Content structure
- All other meta data of interest

`index.qmd` and `content/index.qmd`

- The landing pages with course specific info
- Also, `content/statrecap.qmd` for blog-specific content

`content/material/SeminarDescription.qmd`

- A template for a seminar description

**Other relevant info**

- The actual course pages reside in the directory `content`
- `index.qmd` is the overview page, single lectures are in `content/material/`
- If you want to set up a blog-based content page, such as separate tutorials, or the statistics recap I did for my research methodology course, they need to get a folder here, as well as an `*.qmd` file that serves as a landing page for the blogs
  - Example: you have a directory `statrecap`, then the landing page for these blogs is `statrecap.qmd` in the content directory
  - Within the folders you either create subdirectories with `index.qmd` or `.qmd` files with the respective titles
  - In the directory for the blog you also put `_metadata.yml` with general info
  - You must add the directories to the render heading of `_quarto.yml` such that they get rendered
- References should be in `references/references.bib`


Inspired by [this template](https://github.com/jonjoncardoso/quarto-template-for-university-courses).

