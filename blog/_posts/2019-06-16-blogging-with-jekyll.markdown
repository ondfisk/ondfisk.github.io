---
layout: post
title: Blogging with Jekyll
author: Rasmus Lystrøm
date: 2019-06-15 10:27:44 +0200
updated: 2025-03-03
updated_message: updated with current setup
categories: jekyll
permalink: blogging-with-jekyll/
excerpt_separator: <!--more-->
type: blog
---

I'm very much a fan of [Markdown](https://daringfireball.net/projects/markdown/) for all kinds of documentation and use it where ever I would have used [Word](https://products.office.com/en/word) (shivers!!) or [LaTeX](https://www.latex-project.org/) in the past. This makes [Jekyll](https://jekyllrb.com) for blogging a done deal.

<!--more-->

The code is hosted on [GitHub](https://github.com/ondfisk/ondfisk.dk).

The site is hosted on [Azure Static Web Apps](https://azure.microsoft.com/en-us/products/app-service/static) at [ondfisk.dk](https://ondfisk.dk/).

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
git clone https://github.com/ondfisk/ondfisk.dk.git
cd ondfisk.dk
code .
# Open dev container
cd blog
bundle update
jekyll serve
```

## CI/CD

Build and deploy using GitHub Actions:

`.github/workflows/azure-static-web-apps.yml`:

```yaml
name: Azure Static Web Apps CI/CD

on:
  push:
    branches:
      - main

jobs:
  build_and_deploy_job:
    runs-on: ubuntu-latest
    name: Build and Deploy Job
    permissions:
       id-token: write
       contents: read
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Deploy
        uses: Azure/static-web-apps-deploy@v1
        with:
            ...
        env:
            JEKYLL_ENV: production
```

Inspired by [Getting started with Jekyll blog hosted on Azure static website](https://gunnarpeipman.com/jekyll-azure-devops-static-blog/).
