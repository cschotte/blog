# Blog of Clemens Schotte

This is the source code for my personal blog hosted at [clemens.ms](https://clemens.ms). The blog is built with [Hugo](https://gohugo.io/) using a small custom theme (no third-party theme dependency) and hosted on Azure Blob Storage behind Azure Front Door. GitHub Actions builds and deploys the site when commits are pushed to `main`.

## Tech Stack

- **Static Site Generator**: [Hugo](https://gohugo.io/) (extended)
- **Theme**: custom, built in `layouts/` and `assets/` — no third-party theme
- **Hosting**: Azure Blob Storage behind Azure Front Door
- **Deployment**: GitHub Actions with Azure OpenID Connect authentication
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

After publishing, use Bing Webmaster Tools' URL Inspection and Site Scan to verify the live metadata and
monitor the warning after Bing recrawls the affected pages.

## Deployment

[Build and deploy blog](.github/workflows/deploy.yml) runs automatically on every
push to `main`. Local commits deploy once pushed to GitHub. Pull requests targeting
`main` run the build and metadata checks without deploying. You can also select
**Run workflow** on `main` in the repository's Actions tab.

The workflow installs a pinned Hugo Extended release, verifies its download
checksum, builds the production site, and runs the meta-description check. A
successful build is saved as a GitHub artifact for 14 days. The deployment job
uploads assets before HTML to the `clemens` storage account's `$web` container,
then purges the `clemens` endpoint in the `navatron` Front Door profile. It waits
for the live homepage to match the generated HTML before reporting success.

Deployments run one at a time and an active upload is allowed to finish. Queued
builds superseded by a newer `main` commit skip deployment. Uploads overwrite
matching blob paths and retain existing files absent from the new build. To
remove a published URL, explicitly remove its blob or publish a redirect. Files
have a five-minute browser cache lifetime; the Front Door purge refreshes edge
caches after deployment.

### Azure authentication

The user-assigned managed identity `github-clemens-blog` in resource group
`Clemens` trusts GitHub's OIDC issuer with this exact subject:

```text
repo:cschotte/blog:ref:refs/heads/main
```

The audience is `api://AzureADTokenExchange`. The identity has **Storage Blob Data
Contributor** on the `$web` container and the custom **Clemens Blog Front Door
Cache Purger** role on the blog's Front Door endpoint. The custom role definition
is tracked in [.github/azure-front-door-purge-role.json](.github/azure-front-door-purge-role.json).
The purge runs asynchronously so the identity needs only endpoint read and purge
permissions. Authentication uses short-lived tokens, with no stored client secret
or storage account key.

These repository Actions variables are configured under **Settings → Secrets and
variables → Actions → Variables**:

| Variable | Value |
| --- | --- |
| `AZURE_CLIENT_ID` | `1cada2a3-84a5-4f5d-b69b-76f49e29b675` |
| `AZURE_TENANT_ID` | `9be79373-29bb-4b8a-a999-495ad397f5ae` |
| `AZURE_SUBSCRIPTION_ID` | `e42fceff-ea17-403e-96cd-3337df3043b1` |
| `AZURE_STORAGE_ACCOUNT` | `clemens` |
| `AZURE_FRONT_DOOR_RESOURCE_GROUP` | `NavaTron` |
| `AZURE_FRONT_DOOR_PROFILE` | `navatron` |
| `AZURE_FRONT_DOOR_ENDPOINT` | `clemens` |

### Verification and recovery

Check the workflow run in GitHub Actions for build, upload, and live verification
results. A failed metadata check prevents publication. If an upload or cache purge
fails, fix the cause and rerun the failed deployment job for the current `main`
commit. If a content change needs to be rolled back, revert it and push the revert
to `main`; that creates a new deployment using the restored content.

## Contact

- **Author**: Clemens Schotte
- **Website**: [clemens.ms](https://clemens.ms)
- **LinkedIn**: [linkedin.com/in/cschotte](https://www.linkedin.com/in/cschotte/)
