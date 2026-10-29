# Usage

## Dev Tools

### Theme creator

The theme creator provides a TUI to let you input easily a list of filenames for wallpapers and 16 colors in order to then create a `metadata.json` and compile it to create the same `dotfiles/` structure you'd have from the main provided theme by this repo.

The tool is aimed to make creating themes easy and fast, so that you dont take time in tinkering with files and just pop some colors and files and get going with your new custom theme.

### Theme compiler

The theme compiler is what runs under the hood in the [theme creator](#theme-creator), it takes the `metadata.json` and using Jinja2 templates creates all the files with the same `dotfiles/` structure you'd have from the main provided theme by this repo.

You could skip using the [theme creator](#theme-creator) tool and type manually a `metadata.json` following the schema and then run this tool and you'll get the same results as with the [theme creator](#theme-creator) tool.

### Theme downloader

The theme downloader is made to make sharing themes easier. It takes a URL to a git repo containing a theme with the required structure (explained in [theming](./theming.md#custom-theme-repo-structure)), downloads it and places it inside your rice directory making it ready to use whenever you want.
