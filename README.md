# Blog of Clemens Schotte

This is the source code for my personal blog hosted at [clemens.ms](https://clemens.ms). The blog is built with [Hugo](https://gohugo.io/) using a small custom theme (no third-party theme dependency) and automatically deployed to Azure using GitHub Actions.

## Tech Stack

- **Static Site Generator**: [Hugo](https://gohugo.io/) (extended)
- **Theme**: custom, built in `layouts/` and `assets/` — no third-party theme
- **Hosting**: Azure Blob Storage with Azure CDN
- **Deployment**: GitHub Actions
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

## Contact

- **Author**: Clemens Schotte
- **Website**: [clemens.ms](https://clemens.ms)
- **LinkedIn**: [linkedin.com/in/cschotte](https://www.linkedin.com/in/cschotte/)
