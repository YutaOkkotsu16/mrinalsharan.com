# Writing cheat sheet

## The loop

```bash
./new.sh notes "Post title"        # or: ./new.sh journal "Post title"
quarto preview                     # live preview at http://localhost:4200, reloads on save
# write… then set `draft: false` in the front matter
git add -A && git commit -m "Post: title" && git push   # live in ~1 min
./share.sh notes/2026-10-26-post-title                  # URL + draft X thread + LinkedIn post
```

Drafts (`draft: true`) show in `quarto preview` but are left out of the live
site, listings, feeds, search and sitemap.

Each post is a folder: `notes/YYYY-MM-DD-slug/index.qmd`. Keep images, `.bib`
files and notebooks for that post in the same folder.

## Front matter

```yaml
---
title: "Flash attention from scratch"
description: "One sentence. Used in listings, link previews and ./share.sh."
date: 2026-10-26
categories: [kernels, attention]   # tags; notes has a tag filter
image: figure.png                  # optional: link-preview image for this post
draft: true
---
```

## Formatting

| What | How |
|---|---|
| Image | `![Caption.](plot.png){#fig-plot width=80% fig-alt="Describe it"}` then `@fig-plot` |
| Inline maths | `$\nabla_{\mathbf{r}} E$` |
| Display maths | `$$ E = \sum_i \epsilon_i $$ {#eq-energy}` then `@eq-energy` |
| Code | fenced block with a language: ` ```python ` |
| Footnote | `text.^[The footnote.]` (shows in the margin) |
| Callout | `::: {.callout-note}` … `:::` (also `tip`, `warning`, `important`, `caution`) |
| Collapsed callout | `::: {.callout-tip collapse="true"}` |
| Citation | add `bibliography: refs.bib` to front matter, then `[@key]` or `@key` |
| Wide figure | `::: {.column-page}` … `:::` (or `.column-margin` for a side note) |

See `notes/2026-10-26-example-maths-code-and-figures/` for all of these in use.
It stays a draft, so it is a safe place to experiment.

## Code that runs

Use `{python}` instead of `python` to execute a block when rendering:

````markdown
```{python}
#| label: fig-loss
#| fig-cap: "Training loss."
import matplotlib.pyplot as plt
plt.plot([3, 2, 1.5, 1.2])
```
````

This needs Jupyter in the Python env you write in (`pip install jupyter`).
Results are frozen: the code runs once on your machine (`quarto render path/to/post`)
and the output is saved in `_freeze/`. **Commit `_freeze/`.** CI never runs your
code, so GPU code is fine. A block only re-runs when you edit it.

## Notebooks

- **A notebook as the whole post:** save it as `notes/YYYY-MM-DD-slug/index.ipynb`.
  Put the front matter in a *Raw* cell at the top (same YAML as above).
  Saved outputs are shown as-is; nothing is re-run.
- **Embed one cell from a notebook:** label the cell (`#| label: result`), keep
  the notebook in the post folder with a leading underscore (`_analysis.ipynb`,
  so it isn't published as its own page), then in the post:
  `{{< embed _analysis.ipynb#result >}}`. Readers get a link to the source
  notebook; add `notebook-links: false` to front matter to hide it.

## Comments (giscus, notes only)

One-off setup:

1. Repo Settings → General → Features → tick **Discussions**.
2. Install the giscus app on the repo: <https://github.com/apps/giscus>.
3. Create a Discussions category called **Comments** (type: Announcement, so only
   giscus can start threads).
4. Go to <https://giscus.app>, enter the repo, choose that category, and copy the
   `data-repo-id` and `data-category-id` values.
5. Paste them into `notes/_metadata.yml` and uncomment the `comments:` block.

## Other one-off settings

- **Analytics:** sign up at goatcounter.com, then set your code in
  `_partials/head.html` (search `TODO(goatcounter)`).
- **Photo:** add `assets/photo.jpg` and change `assets/photo.svg` to
  `assets/photo.jpg` in `index.qmd`.
- **Newsletter:** replace the placeholder in `subscribe.qmd`.
- **Google Scholar / email:** search the repo for `TODO(`.
- **Social card:** edit `scripts/social-card.html`, then run
  `scripts/make-social-card.sh`.
