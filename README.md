# Personal site

This repository now uses [Hugo](https://gohugo.io/) with the excellent [hugo-bearblog](https://github.com/janraasch/hugo-bearblog) theme.

## Prerequisites

- Hugo **extended** v0.128.0 or newer (I’m on v0.152.2)

## Local development

```bash
hugo server -D
```

Visit the URL printed in the terminal (usually <http://localhost:1313>). The `-D` flag includes draft content.

## Production build

```bash
scripts/build.sh
```

This runs `hugo --minify` and emits the static site into `docs/`, which GitHub Pages serves.
