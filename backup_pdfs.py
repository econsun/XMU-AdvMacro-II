#!/usr/bin/env python3
"""Back up selected PDFs with a date suffix."""

from __future__ import annotations

import argparse
import os
import re
import shutil
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path


DEFAULT_DESTINATION = Path(
    "/Users/paulsun/Library/Mobile Documents/com~apple~CloudDocs/MyHouse/"
    "05 云端备份/02 笔记备份/bkNote AMaN"
)


@dataclass(frozen=True)
class BackupCopy:
    source: Path
    destination: Path


@dataclass(frozen=True)
class BackupResult:
    removed: tuple[Path, ...]
    copied: tuple[BackupCopy, ...]

    @property
    def removed_count(self) -> int:
        return len(self.removed)

    @property
    def copied_count(self) -> int:
        return len(self.copied)


def backup_name_re(prefix: str) -> re.Pattern[str]:
    return re.compile(
        rf"^{re.escape(prefix)}_(?:One|Two|Chap\d{{2}})_\d{{6}}(?:_.+)?\.pdf$"
    )


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


def remove_existing_backups(destination: Path, prefix: str) -> tuple[Path, ...]:
    removed: list[Path] = []
    if not destination.exists():
        return ()

    name_re = backup_name_re(prefix)
    for pdf in sorted(destination.iterdir(), key=lambda path: path.name):
        if pdf.is_file() and name_re.fullmatch(pdf.name):
            pdf.unlink()
            removed.append(pdf)

    return tuple(removed)


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


def backup_pdfs(root: Path, destination: Path, prefix: str) -> BackupResult:
    root = root.resolve()
    destination = destination.expanduser().resolve()
    destination.mkdir(parents=True, exist_ok=True)

    sources = discover_source_pdfs(root, prefix)
    if not sources:
        raise FileNotFoundError(f"No matching {prefix} full or chapter PDFs were found.")

    removed = remove_existing_backups(destination, prefix)
    date_suffix = datetime.now().strftime("%y%m%d")
    copied: list[BackupCopy] = []

    for source_path in sources:
        backup_name = f"{source_path.stem}_{date_suffix}{source_path.suffix}"
        destination_path = destination / backup_name
        shutil.copy2(source_path, destination_path)
        copied.append(BackupCopy(source=source_path, destination=destination_path))

    return BackupResult(removed=removed, copied=tuple(copied))


def format_summary(
    prefix: str,
    root: Path,
    destination: Path,
    result: BackupResult,
) -> str:
    lines = [
        f"{prefix} PDF backup completed",
        f"  Root:        {root}",
        f"  Destination: {destination}",
        f"  Removed:     {result.removed_count} old backup(s)",
    ]

    if result.removed:
        lines.extend(f"    - {path.name}" for path in result.removed)
    else:
        lines.append("    - (none)")

    lines.append(f"  Copied:      {result.copied_count} PDF(s)")
    if result.copied:
        lines.extend(
            f"    - {item.source.name} -> {item.destination.name}"
            for item in result.copied
        )
    else:
        lines.append("    - (none)")

    return "\n".join(lines)


def main() -> int:
    args = parse_args()

    root = args.root.resolve()
    destination = args.destination.expanduser().resolve()

    result = backup_pdfs(root, destination, args.prefix)
    print(format_summary(args.prefix, root, destination, result))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
