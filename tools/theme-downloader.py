#!/usr/bin/env python3

# =============================================================================
#  Theme Downloader
#  Usage:
#   ./theme-downloader.py {url}               → Download and use metadata name
#   ./theme-downloader.py {url} --name {name} → Download and use custom name
# =============================================================================

# =============================================================================
#  IMPORTS
# =============================================================================
import os
import sys
import json
import shutil
import tempfile
import subprocess
from pathlib import Path

import click
from jsonschema import validate, ValidationError  # type: ignore
import requests

# =============================================================================
#  CONSTANTS & PATH RESOLUTION
# =============================================================================
TOOL_DIR = Path(__file__).resolve().parent
REPO_ROOT = TOOL_DIR.parent
RICE_DIR = Path(
    os.environ.get("RICE_DIR", Path.home() / ".local" / "share" / "rice")
)
THEMES_DIR = RICE_DIR / "themes"
WALLPAPERS_DIR = (
    RICE_DIR / "wallpapers"
)  # Fixed to plural to match global framework

if not THEMES_DIR.exists():
    fallback_themes = REPO_ROOT / "src" / "assets" / "themes"
    if fallback_themes.exists():
        THEMES_DIR = fallback_themes

if not WALLPAPERS_DIR.exists():
    fallback_wallpapers = REPO_ROOT / "src" / "assets" / "wallpapers"
    if fallback_wallpapers.exists():
        WALLPAPERS_DIR = fallback_wallpapers

SCHEMA_URL = "https://raw.githubusercontent.com/dtar380/auto-rice/master/assets/metadata.schema.json"


# =============================================================================
#  METADATA VALIDATOR
# =============================================================================
def fetch_remote_schema() -> dict:
    try:
        response = requests.get(SCHEMA_URL, timeout=5)
        if response.status_code == 200:
            return response.json()
    except Exception:
        pass

    return {
        "type": "object",
        "required": ["name", "colors", "wallpapers", "default_wallpaper"],
    }


def validate_metadata(theme_path: Path) -> bool:
    metadata_file = theme_path / "metadata.json"
    if not metadata_file.is_file():
        return False

    try:
        with open(metadata_file, "r", encoding="utf-8") as f:
            data = json.load(f)

        schema = fetch_remote_schema()
        validate(instance=data, schema=schema)
        return True
    except (json.JSONDecodeError, ValidationError):
        return False


# =============================================================================
#  CLI INTERFACE
# =============================================================================
@click.command()
@click.argument("url", required=True, help="URL to the git repo of the theme.")
@click.option(
    "--name",
    "-n",
    default=None,
    help="Custom target directory name for the theme.",
)
def main(url: str = "", name: str = "") -> None:
    """Download, validate, and install a remote theme repo, syncing wallpapers globally."""
    click.echo(f"[*] Fetching theme from: {url}")

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        clone_dir = tmp_path / "repo"

        try:
            subprocess.run(
                ["git", "clone", "--depth", "1", url, str(clone_dir)],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            )
        except subprocess.CalledProcessError as e:
            click.echo(
                f"[-] Error cloning git repository:\n{e.stderr}", err=True
            )
            sys.exit(1)
        except FileNotFoundError:
            click.echo(
                "[-] Error: 'git' command not found on system.", err=True
            )
            sys.exit(1)

        # 1. Validate root-level metadata schema
        if not validate_metadata(clone_dir):
            click.echo(
                "[-] Error: Theme metadata.json failed public schema validation.",
                err=True,
            )
            sys.exit(1)

        # 2. Read metadata for theme directory naming
        metadata_file = clone_dir / "metadata.json"
        with open(metadata_file, "r", encoding="utf-8") as f:
            meta_data = json.load(f)

        theme_folder_name = (
            name if name else meta_data.get("name", clone_dir.name)
        )
        theme_folder_name = theme_folder_name.strip().lower().replace(" ", "_")
        target_install_path = THEMES_DIR / theme_folder_name

        # 3. Check if target theme already exists and prompt user before replacing
        THEMES_DIR.mkdir(parents=True, exist_ok=True)
        if target_install_path.exists():
            if not click.confirm(
                f"[?] Theme '{theme_folder_name}' already exists. Do you want to replace it?"
            ):
                click.echo("[*] Installation cancelled by user.")
                sys.exit(0)
            shutil.rmtree(target_install_path)

        # 4. Dump/Sync wallpapers into the global system wallpaper directory FIRST
        WALLPAPERS_DIR.mkdir(parents=True, exist_ok=True)
        theme_wps_dir = clone_dir / "wallpapers"

        if theme_wps_dir.is_dir():
            click.echo(
                "[*] Syncing theme wallpapers to global wallpaper directory..."
            )
            for wp_file in theme_wps_dir.iterdir():
                if wp_file.is_file():
                    shutil.copy(wp_file, WALLPAPERS_DIR / wp_file.name)
                    click.echo(f"    [+] Dumped wallpaper: {wp_file.name}")

        # 5. Copy theme into themes/{name}/ and remove wallpapers/ to avoid duplicate files
        shutil.copytree(clone_dir, target_install_path)

        # Strip local wallpapers directory from theme install path
        installed_wps_dir = target_install_path / "wallpapers"
        if installed_wps_dir.exists():
            shutil.rmtree(installed_wps_dir)

        # Strip hidden git meta
        git_meta = target_install_path / ".git"
        if git_meta.exists():
            shutil.rmtree(git_meta)

        click.echo(f"[+] Success! Theme installed to: {target_install_path}")


# =============================================================================
#  MAIN
# =============================================================================
if __name__ == "__main__":
    main()
