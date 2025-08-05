# Blog of Clemens Schotte

[![Deploy Status](https://github.com/cschotte/Blog/actions/workflows/deploy.yml/badge.svg)](https://github.com/cschotte/Blog/actions/workflows/deploy.yml)

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

## 🚀 Getting Started

### Prerequisites

- [Hugo Extended](https://gohugo.io/installation/) v0.148.1 or later
- [Git](https://git-scm.com/)
- [Node.js](https://nodejs.org/) (optional, for theme development)

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/cschotte/Blog.git
   cd Blog
   ```

2. **Install Hugo** (if not already installed)
   ```bash
   # macOS (using Homebrew)
   brew install hugo
   
   # Or download from https://github.com/gohugoio/hugo/releases
   ```

3. **Start the development server**
   ```bash
   hugo server --buildDrafts --buildFuture --disableFastRender --ignoreCache --watch
   ```
   
   Or use the VS Code task:
   ```bash
   # In VS Code: Ctrl+Shift+P → "Tasks: Run Task" → "Hugo: Serve Development"
   ```

4. **Open your browser**
   - Navigate to `http://localhost:1313`
   - The site will automatically reload when you make changes

## ✍️ Creating Content

### New Blog Post

1. **Create a new post**
   ```bash
   hugo new posts/your-post-title/index.md
   ```

2. **Edit the post**
   - Open the created file in `content/posts/your-post-title/index.md`
   - Update the front matter (title, date, tags, etc.)
   - Write your content in Markdown
   - Add images to the same folder if needed

3. **Example front matter**
   ```yaml
   ---
   title: "Your Amazing Post Title"
   date: 2025-08-05T10:00:00Z
   draft: false
   tags: ["technology", "azure", "programming"]
   categories: ["Blog"]
   featuredImage: "featured-image.jpg"
   summary: "A brief description of your post"
   ---
   ```

### New Page

```bash
hugo new about.md
# Edit content/about.md
```

## 🧪 Testing

### Local Testing

1. **Build the site locally**
   ```bash
   hugo --minify --gc --environment production
   ```
   
   Or use the VS Code task:
   ```bash
   # In VS Code: Ctrl+Shift+P → "Tasks: Run Task" → "Hugo: Build Production"
   ```

2. **Serve the built site**
   ```bash
   # Serve the public folder
   cd public && python3 -m http.server 8000
   ```

3. **Clean build artifacts**
   ```bash
   hugo --gc --cleanDestinationDir
   ```
   
   Or use the VS Code task:
   ```bash
   # In VS Code: Ctrl+Shift+P → "Tasks: Run Task" → "Hugo: Clean"
   ```

### Content Validation

- **Check for draft posts**: Ensure `draft: false` in front matter
- **Validate links**: Test internal and external links
- **Image optimization**: Compress images before adding
- **SEO**: Verify meta descriptions and titles

## 🚢 Deployment

The blog is automatically deployed using GitHub Actions when changes are pushed to the `master` branch.

### Automatic Deployment

1. **Push to master**
   ```bash
   git add .
   git commit -m "Add new blog post"
   git push origin master
   ```

2. **GitHub Actions will**:
   - Build the Hugo site
   - Upload files to Azure Blob Storage
   - Purge Azure CDN cache
   - Make the changes live at [clemens.ms](https://clemens.ms)

### Manual Deployment

You can also trigger deployment manually:
1. Go to [GitHub Actions](https://github.com/cschotte/Blog/actions)
2. Select "Build and Deploy Hugo site to Azure Blob Storage"
3. Click "Run workflow"

### Deployment Configuration

The deployment requires these GitHub secrets:
- `AZURE_CREDENTIALS`: Azure service principal credentials
- `AZURE_STORAGE_ACCOUNT`: Azure storage account name
- `AZURE_RESOURCE_GROUP`: Azure resource group name
- `AZURE_CDN_PROFILE_NAME`: Azure CDN profile name
- `AZURE_CDN_ENDPOINT_NAME`: Azure CDN endpoint name

## 🛠️ Available Commands

### VS Code Tasks
- **Hugo: Serve Development**: Start development server
- **Hugo: Build Production**: Build for production
- **Hugo: Clean**: Clean build artifacts

### Hugo Commands
```bash
# Development
hugo server -D                    # Serve with drafts
hugo server --disableFastRender  # Disable fast render for debugging

# Building
hugo                             # Build site
hugo --minify                    # Build and minify
hugo --gc                        # Build with garbage collection

# Content
hugo new posts/post-name/index.md # Create new post
hugo new page-name.md            # Create new page
```

## 🎨 Customization

### Theme Configuration
- Edit `hugo.toml` for site-wide settings
- Customize layouts in `layouts/` folder
- Add custom CSS/JS in `static/` folder

### Adding Features
- Custom shortcodes in `layouts/shortcodes/`
- Custom page layouts in `layouts/_default/`
- Additional static assets in `static/`

## 📝 Writing Tips

- Use clear, descriptive titles
- Add relevant tags and categories
- Include a featured image when possible
- Write engaging summaries for social sharing
- Use proper heading hierarchy (H1, H2, H3...)
- Optimize images for web (WebP format recommended)

## 🔗 Useful Links

- **Live Site**: [clemens.ms](https://clemens.ms)
- **Hugo Documentation**: [gohugo.io/documentation](https://gohugo.io/documentation/)
- **LoveIt Theme**: [hugoloveit.com](https://hugoloveit.com/)
- **Markdown Guide**: [markdownguide.org](https://www.markdownguide.org/)
- **GitHub Actions**: [docs.github.com/actions](https://docs.github.com/en/actions)

## 📧 Contact

- **Author**: Clemens Schotte
- **Website**: [clemens.ms](https://clemens.ms)
- **LinkedIn**: [linkedin.com/in/cschotte](https://www.linkedin.com/in/cschotte/)

---

> **Note**: The opinions expressed in this blog are my own and do not necessarily represent those of Microsoft.
