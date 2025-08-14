# GitHub Copilot Instructions for Clemens Schotte's Blog

This is a **Hugo-based static blog** deployed to Azure using GitHub Actions. The site focuses on Azure, DevOps, and technical content.

## Project Architecture

**Hugo Setup**: Uses LoveIt theme with custom layouts in `layouts/`. Configuration in `hugo.toml` defines menus, theme settings, and Azure-specific features like CDN integration.

**Content Structure**: 
- Blog posts in `content/posts/[post-name]/index.md` with co-located assets
- Each post has YAML frontmatter with `title`, `author`, `date`, `tags`, `categories`, `featuredImage`, `draft`
- Static pages in `content/` root (about.md, resume.md, etc.)

**Deployment Pipeline**: GitHub Actions workflow (`.github/workflows/deploy.yml`) builds Hugo site and deploys to Azure Blob Storage + CDN on pushes to `main` branch.

## Development Workflow

**Local Development**:
```bash
# Use VS Code task "Hugo: Serve Development" or:
hugo server --buildDrafts --buildFuture --disableFastRender --ignoreCache --watch
```

**Creating Content**:
```bash
hugo new posts/post-title/index.md
# Edit frontmatter and content, set draft: false when ready
```

**Production Build**:
```bash
# Use VS Code task "Hugo: Build Production" or:
hugo --minify --gc --environment production
```

## Azure Infrastructure Pattern

This blog follows a **static site + CDN** pattern common in the author's content:
- Azure Blob Storage for hosting (with static website feature enabled)
- Azure CDN for global distribution and HTTPS
- GitHub Actions for CI/CD using Azure service principal authentication

## Content Conventions

**Post Structure**: Each technical post typically includes:
- Introduction with business context
- Step-by-step implementation with Azure CLI commands
- Architecture diagrams (often as PNG files)
- Code samples with proper syntax highlighting
- Security considerations and best practices

**Azure Focus**: Content heavily emphasizes Azure services, DevOps practices, and Infrastructure as Code patterns. Posts often include actual deployment scripts and configuration examples.

**Code Samples**: Frequently includes PowerShell, Azure CLI, ARM templates, and C# code. Commands are formatted for copy-paste execution.

## Key Files to Understand

- `hugo.toml` - Site configuration, theme settings, menu structure
- `content/posts/*/index.md` - Blog post structure and frontmatter patterns
- `.github/workflows/deploy.yml` - Azure deployment automation
- `layouts/` - Custom Hugo template overrides for LoveIt theme

When adding new content, follow the established pattern of technical depth with practical implementation examples, especially for Azure-related topics.
