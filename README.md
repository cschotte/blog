# Blog of Clemens Schotte

This is the source code for my personal blog hosted at [clemens.ms](https://clemens.ms). The blog is built with [Hugo](https://gohugo.io/) using the [LoveIt](https://github.com/dillonzq/LoveIt) theme and automatically deployed to Azure using GitHub Actions.

## 🏗️ Tech Stack

- **Static Site Generator**: [Hugo](https://gohugo.io/) v0.148.1
- **Theme**: [LoveIt](https://github.com/dillonzq/LoveIt)
- **Hosting**: Azure Blob Storage with Azure CDN
- **Deployment**: GitHub Actions
- **Domain**: Custom domain [clemens.ms](https://clemens.ms)

## 📁 Project Structure

```
├── content/                 # Blog content and pages
│   ├── posts/              # Blog posts
│   ├── about.md            # About page
│   ├── privacy-policy.md   # Privacy policy
│   ├── resume.md           # Resume page
│   └── terms-of-use.md     # Terms of use
├── layouts/                # Custom Hugo layouts
├── static/                 # Static assets (images, icons, etc.)
├── themes/LoveIt/          # Hugo theme
├── .github/workflows/      # GitHub Actions workflows
├── hugo.toml              # Hugo configuration
└── README.md              # This file
```

## AI Press Kit

The site includes an AI Press Kit to help AI assistants, search engines, and citation tools describe Clemens Schotte and clemens.ms accurately. The public files are generated from `static/` and published at `/llms.txt`, `/llms-full.txt`, `/person.json`, `/projects.json`, `/topics.json`, and `/ai-index.json`. Hugo also emits supplemental JSON-LD for the website, Clemens as a person, NavaTron B.V., blog posts, and selected project pages.

## 📧 Contact

- **Author**: Clemens Schotte
- **Website**: [clemens.ms](https://clemens.ms)
- **LinkedIn**: [linkedin.com/in/cschotte](https://www.linkedin.com/in/cschotte/)
