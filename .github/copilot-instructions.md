# Copilot Instructions — harmonyhu.github.io

Personal technical blog built with Jekyll using a fully custom hand-rolled theme. No upstream theme gem is used. Published at <https://harmonyhu.com>.

## Local development

```bash
bundle install          # install Ruby gems
bundle exec jekyll serve  # serve at http://127.0.0.1:4000
```

There is **no Node/npm build step** and no `package.json`. Files under `assets/js/` and `assets/css/` are served as-is; edits take effect on the next Jekyll rebuild.

## Architecture overview

```
_layouts/       # Page layouts: default → home/post/page/archive/categories/tags/single
_includes/      # Reusable partials: head, header, footer, comments, paginator,
                #   post-nav, search-modal, svg-icons
_sass/          # SCSS partials imported by assets/css/main.scss
                #   _variables, _reset, _base, _layout, _components, _post,
                #   _responsive, _syntax
_posts/         # Blog posts (Markdown, YYYY-MM-DD-Title.md)
_pages/         # Standalone pages: about, archive, categories, tags, 404
assets/         # Compiled CSS, JS (main.js), and images — no bundler
search.json     # Jekyll-generated search index consumed by the search modal
temporary/      # Draft posts excluded from the build (_config.yml exclude)
```

The layout chain is: every page extends `default.html`, which pulls in `head.html`, `header.html`, and `footer.html`. Posts use `post.html → default.html`.

## Post front matter

```yaml
---
layout: post          # default for _posts via _config.yml defaults
title: "Post Title"
categories:
  - CategoryName
tags:
  - tag1
  - tag2
toc: true             # omit or set true to show TOC; set false to hide
comments: true        # omit to use site default; set false to disable
mathjax: true         # include only when the post contains LaTeX math
---
```

`<!--more-->` marks the excerpt boundary used on the home/archive listing.

## Key conventions

- **Theme switching** — light/dark is toggled in `assets/js/main.js` and persisted in `localStorage`. The initial theme is set inline in `_includes/head.html` (before CSS loads) to prevent flash of incorrect theme. The `[data-theme="dark"]` attribute on `<html>` drives all dark-mode CSS via custom properties in `_sass/_variables.scss`.

- **CSS custom properties** — all colours, spacing, typography, and shadow tokens are CSS variables defined in `_sass/_variables.scss` under `:root` (light) and `[data-theme="dark"]`. Avoid hardcoding colour values in other SCSS files; reference variables instead.

- **MathJax** — loaded conditionally on every page unless `mathjax: false` is set in front matter. MathJax is configured in `_includes/head.html` with `$…$` / `$$…$$` delimiters. polyfill.io is **not** used.

- **Comments** — rendered via [Giscus](https://giscus.app/) (GitHub Discussions) in `_includes/comments.html`. Shown when `site.comments.enabled: true` AND `page.comments != false`.

- **TOC** — generated client-side by `assets/js/main.js` and injected into `<div id="toc">` in `_layouts/post.html`. Shown unless `toc: false` in front matter.

- **Pagination** — `jekyll-paginate` at 10 posts per page; paginator include is `_includes/paginator.html`.

- **Permalink format** — `/:year/:month/:day/:title/` (set in `_config.yml`).

- **Drafts** — place unfinished posts in `temporary/` (excluded from build) rather than using Jekyll's `_drafts/` mechanism.

- **Markdown renderer** — kramdown with GFM input and Rouge for syntax highlighting. No custom plugins or shortcodes.
