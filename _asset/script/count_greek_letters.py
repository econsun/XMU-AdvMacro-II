#!/usr/bin/env python3
"""Count Greek letter usage in AMaN source files."""

from __future__ import annotations

import argparse
import re
from collections import Counter
from pathlib import Path


DEFAULT_SCAN_DIR = Path("200_MainMatter")
TEXT_SUFFIXES = {".tex"}

LOWERCASE_COMMANDS = (
    "alpha",
    "beta",
    "gamma",
    "delta",
    "epsilon",
    "varepsilon",
    "zeta",
    "eta",
    "theta",
    "vartheta",
    "iota",
    "kappa",
    "lambda",
    "mu",
    "nu",
    "xi",
    "omicron",
    "pi",
    "varpi",
    "rho",
    "varrho",
    "sigma",
    "varsigma",
    "tau",
    "upsilon",
    "phi",
    "varphi",
    "chi",
    "psi",
    "omega",
)

UPPERCASE_COMMANDS = (
    "Alpha",
    "Beta",
    "Gamma",
    "Delta",
    "Epsilon",
    "Zeta",
    "Eta",
    "Theta",
    "Iota",
    "Kappa",
    "Lambda",
    "Mu",
    "Nu",
    "Xi",
    "Omicron",
    "Pi",
    "Rho",
    "Sigma",
    "Tau",
    "Upsilon",
    "Phi",
    "Chi",
    "Psi",
    "Omega",
)

UNICODE_TO_COMMAND = {
    "α": "alpha",
    "β": "beta",
    "γ": "gamma",
    "δ": "delta",
    "ε": "epsilon",
    "ϵ": "epsilon",
    "ζ": "zeta",
    "η": "eta",
    "θ": "theta",
    "ϑ": "vartheta",
    "ι": "iota",
    "κ": "kappa",
    "λ": "lambda",
    "μ": "mu",
    "ν": "nu",
    "ξ": "xi",
    "ο": "omicron",
    "π": "pi",
    "ϖ": "varpi",
    "ρ": "rho",
    "ϱ": "varrho",
    "σ": "sigma",
    "ς": "varsigma",
    "τ": "tau",
    "υ": "upsilon",
    "φ": "phi",
    "ϕ": "varphi",
    "χ": "chi",
    "ψ": "psi",
    "ω": "omega",
    "Α": "Alpha",
    "Β": "Beta",
    "Γ": "Gamma",
    "Δ": "Delta",
    "Ε": "Epsilon",
    "Ζ": "Zeta",
    "Η": "Eta",
    "Θ": "Theta",
    "Ι": "Iota",
    "Κ": "Kappa",
    "Λ": "Lambda",
    "Μ": "Mu",
    "Ν": "Nu",
    "Ξ": "Xi",
    "Ο": "Omicron",
    "Π": "Pi",
    "Ρ": "Rho",
    "Σ": "Sigma",
    "Τ": "Tau",
    "Υ": "Upsilon",
    "Φ": "Phi",
    "Χ": "Chi",
    "Ψ": "Psi",
    "Ω": "Omega",
}

COMMAND_TO_UNICODE = {
    command: symbol
    for symbol, command in UNICODE_TO_COMMAND.items()
    if not command.startswith("var")
}
COMMAND_TO_UNICODE.update(
    {
        "varepsilon": "ε",
        "vartheta": "ϑ",
        "varpi": "ϖ",
        "varrho": "ϱ",
        "varsigma": "ς",
        "varphi": "ϕ",
    }
)


def find_repo_root(start: Path) -> Path:
    for candidate in (start, *start.parents):
        if (candidate / "Makefile").is_file() and (candidate / DEFAULT_SCAN_DIR).is_dir():
            return candidate

    return start


def parse_args() -> argparse.Namespace:
    repo_root = find_repo_root(Path(__file__).resolve().parent)

    parser = argparse.ArgumentParser(
        description="Count LaTeX Greek letter commands and literal Greek letters."
    )
    parser.add_argument(
        "path",
        nargs="?",
        type=Path,
        default=repo_root / DEFAULT_SCAN_DIR,
        help="Directory or file to scan. Defaults to 200_MainMatter.",
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="Show letters with zero occurrences too.",
    )
    return parser.parse_args()


def iter_source_files(path: Path) -> list[Path]:
    if path.is_file():
        return [path]

    return sorted(
        item
        for item in path.rglob("*")
        if item.is_file() and item.suffix.lower() in TEXT_SUFFIXES
    )


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return path.read_text(encoding="latin-1")


def count_greek_letters(paths: list[Path]) -> Counter[str]:
    commands = LOWERCASE_COMMANDS + UPPERCASE_COMMANDS
    command_re = re.compile(
        r"\\(" + "|".join(re.escape(command) for command in commands) + r")(?![A-Za-z])"
    )
    unicode_re = re.compile("[" + re.escape("".join(UNICODE_TO_COMMAND)) + "]")
    counts: Counter[str] = Counter()

    for path in paths:
        text = read_text(path)
        counts.update(match.group(1) for match in command_re.finditer(text))
        counts.update(UNICODE_TO_COMMAND[match.group(0)] for match in unicode_re.finditer(text))

    return counts


def format_table(title: str, commands: tuple[str, ...], counts: Counter[str], show_all: bool) -> str:
    order = {command: index for index, command in enumerate(commands)}
    rows = sorted(
        ((command, counts[command]) for command in commands if show_all or counts[command]),
        key=lambda row: (-row[1], order[row[0]]),
    )
    if not rows:
        return f"{title} | total: 0\n  (none)"

    total = sum(count for _, count in rows)
    name_width = max(len(command) for command, _ in rows)
    count_width = max(len("Count"), *(len(str(count)) for _, count in rows))
    rank_width = max(4, len(str(len(rows))))
    command_width = max(7, name_width + 1)
    lines = [
        f"{title} | total: {total}",
        (
            f"{'Rank':>{rank_width}}  {'Letter':<6}  "
            f"{'Command':<{command_width}}  {'Count':>{count_width}}  Share"
        ),
        (
            f"{'-' * rank_width}  {'-' * 6}  "
            f"{'-' * command_width}  {'-' * count_width}  {'-' * 6}"
        ),
    ]
    lines.extend(
        (
            f"{rank:>{rank_width}}  {COMMAND_TO_UNICODE.get(command, ''):<6}  "
            f"{'\\' + command:<{command_width}}  {count:>{count_width}}  "
            f"{count / total:>5.1%}"
        )
        for rank, (command, count) in enumerate(rows, start=1)
    )
    return "\n".join(lines)


def main() -> int:
    args = parse_args()
    scan_path = args.path.expanduser().resolve()

    if not scan_path.exists():
        raise FileNotFoundError(f"Scan path does not exist: {scan_path}")

    files = iter_source_files(scan_path)
    counts = count_greek_letters(files)
    total_count = sum(
        counts[command]
        for command in (*LOWERCASE_COMMANDS, *UPPERCASE_COMMANDS)
    )

    print("Greek Letter Usage")
    print("==================")
    print(f"Scan path : {scan_path}")
    print(f"File types: {', '.join(sorted(TEXT_SUFFIXES))}")
    print(f"Files     : {len(files)}")
    print(f"Total     : {total_count}")
    print()
    print(format_table("Lowercase", LOWERCASE_COMMANDS, counts, args.all))
    print()
    print(format_table("Uppercase", UPPERCASE_COMMANDS, counts, args.all))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
