---
layout: post
title: "Blogging with Jekyll"
categories: azure devops jekyll
permalink: /blogging-with-jekyll/
---

I'm very much a fan of [Markdown](https://daringfireball.net/projects/markdown/) for all kinds of documentation and use it where ever I would have used [Word](https://products.office.com/en/word) (shivers!!) or [LaTeX](https://www.latex-project.org/) in the past. This makes [Jekyll](https://jekyllrb.com) for blogging a done deal.

The code is hosted on [Azure DevOps Services](https://dev.azure.com/ondfisk/ondfisk.dk).

The site is hosted on [Azure App Service](https://www.ondfisk.dk).

Debugging locally (using [WSL2](https://docs.microsoft.com/en-us/windows/wsl/wsl2-index) in [Visual Studio Code](https://code.visualstudio.com/)):

```bash
sudo apt-get install -y ruby-full build-essential zlib1g-dev
echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

gem install bundler
gem install jekyll
bundle update
cd blog
jekyll serve
```

Build and deploy using `azure-pipelines.yml`:

```yaml

```

Inspired by <https://gunnarpeipman.com/series/jekyll-azure-devops-static-website/>.
