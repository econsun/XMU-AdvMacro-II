#!/usr/bin/env python3
"""Back up selected PDFs with a date suffix."""

from __future__ import annotations

import argparse
import os
import re
import shutil
from datetime import datetime
from pathlib import Path


DEFAULT_DESTINATION = Path(
    "/Users/paulsun/Library/Mobile Documents/com~apple~CloudDocs/MyHouse/"
    "05 云端备份/02 笔记备份/bkNote AMaN"
)


def backup_name_re(prefix: str) -> re.Pattern[str]:
    return re.compile(rf"^{re.escape(prefix)}_(?:One|Two|Chap\d{{2}})_\d{{6}}\.pdf$")


def full_name_re(prefix: str) -> re.Pattern[str]:
    return re.compile(rf"^{re.escape(prefix)}_(?:One|Two)\.pdf$")


def chapter_name_re(prefix: str) -> re.Pattern[str]:
    return re.compile(rf"^{re.escape(prefix)}_Chap\d{{2}}\.pdf$")


def parse_args() -> argparse.Namespace:
    script_dir = Path(__file__).resolve().parent

    parser = argparse.ArgumentParser(
        description="Back up AMaN full and chapter PDFs to a flat destination folder."
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=script_dir,
        help="Repository root. Defaults to this script's directory.",
    )
    parser.add_argument(
        "--destination",
        type=Path,
        default=DEFAULT_DESTINATION,
        help="Backup destination folder.",
    )
    parser.add_argument(
        "--prefix",
        default=os.environ.get("PDF_PREFIX", "AMaN"),
        help="PDF filename prefix. Defaults to PDF_PREFIX or AMaN.",
    )
    return parser.parse_args()


def remove_existing_backups(destination: Path, prefix: str) -> int:
    removed = 0
    if not destination.exists():
        return removed

    name_re = backup_name_re(prefix)
    for pdf in destination.iterdir():
        if pdf.is_file() and name_re.fullmatch(pdf.name):
            pdf.unlink()
            removed += 1

    return removed


def discover_source_pdfs(root: Path, prefix: str) -> list[Path]:
    pdf_dir = root / "900_PDF"
    full_re = full_name_re(prefix)
    chapter_re = chapter_name_re(prefix)

    sources = [
        pdf
        for pdf in pdf_dir.rglob("*.pdf")
        if (
            pdf.parent.name == "01_Full"
            and full_re.fullmatch(pdf.name)
        )
        or (
            pdf.parent.name == "03_Chapters"
            and chapter_re.fullmatch(pdf.name)
        )
    ]

    return sorted(sources, key=lambda pdf: pdf.name)


def backup_pdfs(root: Path, destination: Path, prefix: str) -> tuple[int, int]:
    root = root.resolve()
    destination = destination.expanduser().resolve()
    destination.mkdir(parents=True, exist_ok=True)

    sources = discover_source_pdfs(root, prefix)
    if not sources:
        raise FileNotFoundError(f"No matching {prefix} full or chapter PDFs were found.")

    removed = remove_existing_backups(destination, prefix)
    date_suffix = datetime.now().strftime("%y%m%d")

    for source_path in sources:
        backup_name = f"{source_path.stem}_{date_suffix}{source_path.suffix}"
        shutil.copy2(source_path, destination / backup_name)

    return removed, len(sources)


def main() -> int:
    args = parse_args()

    root = args.root.resolve()
    destination = args.destination.expanduser().resolve()

    removed, copied = backup_pdfs(root, destination, args.prefix)
    print(f"{args.prefix} PDF backup: removed {removed}, copied {copied} to {destination}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())