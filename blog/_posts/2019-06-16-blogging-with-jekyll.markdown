---
layout: post
title: Blogging with Jekyll
author: Rasmus Lystrøm
date: 2019-06-15 10:27:44 +0200
updated: 2025-03-22
updated_message: moved to GitHub Pages
categories: jekyll
permalink: blogging-with-jekyll/
excerpt_separator: <!--more-->
type: blog
---

I'm very much a fan of [Markdown](https://daringfireball.net/projects/markdown/) for all kinds of documentation and use it where ever I would have used [Word](https://products.office.com/en/word) (shivers!!) or [LaTeX](https://www.latex-project.org/) in the past. This makes [Jekyll](https://jekyllrb.com) for blogging a done deal.

<!--more-->

The code is hosted on [GitHub](https://github.com/ondfisk/ondfisk.github.io).

The site is hosted on [GitHub Pages](https://pages.github.com/) at [ondfisk.dk](https://ondfisk.dk/).

## Development

Working with Jekyll locally is made easy using a [development container](https://containers.dev/) (requires [Docker](https://www.docker.com/products/docker-desktop/)):

`.devcontainer/devcontainer.json`:

```json
{
    "name": "Jekyll",
    "image": "mcr.microsoft.com/devcontainers/jekyll:dev-3.3-bookworm",
    "customizations": {
        "vscode": {
            "settings": {},
            "extensions": [
                "davidanson.vscode-markdownlint",
                "esbenp.prettier-vscode",
                "github.vscode-pull-request-github",
                "redhat.vscode-yaml",
                "shopify.ruby-extensions-pack",
                "streetsidesoftware.code-spell-checker"
            ]
        }
    }
}
```

## Debug

To run the site locally (using [WSL2](https://learn.microsoft.com/en-us/windows/wsl/)):

```bash
git clone https://github.com/ondfisk/ondfisk.github.io.git
cd ondfisk.dk
code .
# Open dev container
cd blog
bundle update
jekyll serve
```

## CI/CD

Build and deploy using GitHub Actions:

`.github/workflows/pages.yml`:

```yaml
name: Deploy site to Pages

on:
  push:
    branches:
      - main

  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.3
          bundler-cache: true
          working-directory: blog/
      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v5
      - name: Build with Jekyll
        run: |
          bundle exec jekyll build --baseurl "${{ steps.pages.outputs.base_path }}"
        env:
          JEKYLL_ENV: production
        working-directory: blog/
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: blog/_site

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

Inspired by [Getting started with Jekyll blog hosted on Azure static website](https://gunnarpeipman.com/jekyll-azure-devops-static-blog/).
