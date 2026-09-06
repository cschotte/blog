# Blog of Clemens Schotte

This is the source code for my personal blog hosted at [clemens.ms](https://clemens.ms). The blog is built with [Hugo](https://gohugo.io/) using a small custom theme (no third-party theme dependency) and hosted on Azure Blob Storage behind Azure Front Door. Deployment configuration is managed outside this repository.

## Tech Stack

- **Static Site Generator**: [Hugo](https://gohugo.io/) (extended)
- **Theme**: custom, built in `layouts/` and `assets/` — no third-party theme
- **Hosting**: Azure Blob Storage behind Azure Front Door
- **Deployment**: Managed outside this repository
- **Domain**: Custom domain [clemens.ms](https://clemens.ms)

## Project Structure

```
├── content/                 # Blog content and pages
│   ├── posts/               # Blog posts (page bundles: index.md + images)
│   ├── about.md, resume.md, privacy-policy.md, terms-of-use.md
├── layouts/                 # Custom Hugo templates (the theme)
│   ├── _default/            # baseof, single, list, term, taxonomy, markdown output
│   ├── partials/             # head, header, footer, article-card, article-meta, seo, json-ld, comments
│   ├── index.html, index.json, index.llms.txt, index.llmsfull.txt
│   └── robots.txt, sitemap.xml, 404.html
├── assets/
│   ├── css/main.css         # entire stylesheet (no framework, no build step)
│   └── js/theme.js          # theme toggle, code copy button, native share
├── data/llms.yaml           # curated bio/project text used by the llms.txt templates
├── static/                  # favicons, images, fonts (self-hosted Roboto), self-hosted KaTeX
├── hugo.toml                # Hugo configuration
└── README.md                # This file
```

## Meta descriptions

Write a specific `description` in a page's YAML front matter, aiming for 150–160
characters that summarize its content. Tag and category descriptions live in
their `content/tags/<tag>/_index.md` and `content/categories/<category>/_index.md`
files. Add an `_index.md` when introducing a new tag. The homepage description is
configured in `hugo.toml`; the posts archive uses `content/posts/_index.md`.

The SEO template uses these descriptions for search, Open Graph, and Twitter
metadata. Pages without an explicit description fall back to their article
summary or the site description.

Build and check the rendered HTML before publishing:

```sh
hugo --destination /tmp/clemens-blog-seo --cleanDestinationDir
python3 scripts/check_meta_descriptions.py /tmp/clemens-blog-seo
```

The check fails for missing, duplicate, or short description tags and mismatched
social descriptions. It skips redirects and pages marked `noindex`. Descriptions
over 160 characters are reported as informational: the target is an editorial
guideline, and existing article summaries may be longer.

Deployment is managed outside this repository. After publishing, use Bing
Webmaster Tools' URL Inspection and Site Scan to verify the live metadata and
monitor the warning after Bing recrawls the affected pages.

## Contact

- **Author**: Clemens Schotte
- **Website**: [clemens.ms](https://clemens.ms)
- **LinkedIn**: [linkedin.com/in/cschotte](https://www.linkedin.com/in/cschotte/)
