# [ondfisk.dk](https://ondfisk.dk/)

Source code for [ondfisk.dk](https://ondfisk.dk/).

## Run

Open in Dev Container and:

```bash
cd blog
bundle update --all
jekyll serve
```

## Lint

To lint repository locally run (from host, not inside dev container):

```bash
docker run \
-e DEFAULT_BRANCH=main \
-e RUN_LOCAL=true \
-e IGNORE_GITIGNORED_FILES=true \
-e VALIDATE_BIOME_LINT=false \
-e VALIDATE_CSS=false \
-e VALIDATE_CSS_PRETTIER=false \
-e VALIDATE_GIT_COMMITLINT=false \
-e VALIDATE_GITLEAKS=false \
-e VALIDATE_GRAPHQL_PRETTIER=false \
-e VALIDATE_HTML=false \
-e VALIDATE_HTML_PRETTIER=false \
-e VALIDATE_JAVASCRIPT_ES=false \
-e VALIDATE_JAVASCRIPT_PRETTIER=false \
-e VALIDATE_JSON=false \
-e VALIDATE_JSON_PRETTIER=false \
-e VALIDATE_JSONC=false \
-e VALIDATE_JSONC_PRETTIER=false \
-e VALIDATE_JSX=false \
-e VALIDATE_JSX_PRETTIER=false \
-e VALIDATE_PYTHON_RUFF=false \
-e VALIDATE_PYTHON_RUFF_FORMAT=false \
-e VALIDATE_SPELL_CODESPELL=false \
-e VALIDATE_TSX=false \
-e VALIDATE_TYPESCRIPT_ES=false \
-e VALIDATE_TYPESCRIPT_PRETTIER=false \
-e VALIDATE_VUE=false \
-e VALIDATE_VUE_PRETTIER=false \
-e FIX_BIOME_FORMAT=true \
-e FIX_GITHUB_ACTIONS_ZIZMOR=true \
-e FIX_MARKDOWN_PRETTIER=true \
-e FIX_MARKDOWN=true \
-e FIX_NATURAL_LANGUAGE=true \
-e FIX_YAML_PRETTIER=true \
-v .:/tmp/lint \
--platform linux/amd64 \
--rm ghcr.io/super-linter/super-linter:latest
```
