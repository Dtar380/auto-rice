# Theming

## Theme structure

Themes structure them selves as follows:

- metadata.json (folowing the schema)
- preview image (both png and jpg supported)
- same folder structure as in `dotfiles/`:
  - colors file (file type will be the one required by said app)

## Creating a custom theme

To create a custom theme you can either use our designed [tool](./usage.md#theme-creator) to create themes or you can manually create one.

You can also create a `metadata.json` file and let our designed [tool](./usage.md#theme-compiler) create all the dotfiles for you, this is similar to using the creator tool but skipping the TUI.

```{note}
The tool has its limitations when it comes to color palletes, so manually created themes can be more customized since you can use colors outside the metadata.json palette.
```

## Custom theme repo structure

If you want to make your theme sharable for everyone, you can create a git repo following this structure:

- README
- LICENSE
- metadata.json
- `dotfiles/`
- `wallpapers/`

The dotfiles directory will contain the same as our normal `theme/{name}` directory when installed inside the `rice` directory, and inside it we will have all the folders for all the apps the rice uses with its defined colors file with the file type required for each app.

The wallpapers directory will contain all the wallpapers that this theme will have specified inside its `metadata.json`.

## Downloading a custom theme

You can download any theme published in a git repository using our designed [tool](./usage.md#theme-downloader).
