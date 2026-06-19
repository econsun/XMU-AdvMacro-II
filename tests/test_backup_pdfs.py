from __future__ import annotations

import io
import sys
import tempfile
import unittest
from contextlib import redirect_stdout
from datetime import datetime
from pathlib import Path
from unittest.mock import patch

import backup_pdfs


class FixedDateTime(datetime):
    @classmethod
    def now(cls) -> "FixedDateTime":
        return cls(2026, 6, 19)


class BackupPdfsTest(unittest.TestCase):
    def write_pdf(self, path: Path, content: bytes = b"%PDF-test\n") -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(content)

    def test_backup_removes_tailed_existing_backup_and_uses_expected_name(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            tmp = Path(tmpdir)
            root = tmp / "repo"
            destination = tmp / "backup"

            self.write_pdf(root / "900_PDF/01_Full/AMaN_One.pdf", b"full")
            self.write_pdf(root / "900_PDF/03_Chapters/AMaN_Chap08.pdf", b"chapter")

            self.write_pdf(destination / "AMaN_One_260619_old.pdf", b"old full")
            self.write_pdf(destination / "AMaN_Chap08_260619.pdf", b"old chapter")
            self.write_pdf(destination / "AMaN_Chap08_260619_NK基本情况.pdf", b"old tail")
            self.write_pdf(destination / "Other_Chap08_260619_NK.pdf", b"keep")

            with patch("backup_pdfs.datetime", FixedDateTime):
                result = backup_pdfs.backup_pdfs(root, destination, "AMaN")

            self.assertEqual(result.removed_count, 3)
            self.assertEqual(result.copied_count, 2)
            self.assertEqual(
                [path.name for path in result.removed],
                [
                    "AMaN_Chap08_260619.pdf",
                    "AMaN_Chap08_260619_NK基本情况.pdf",
                    "AMaN_One_260619_old.pdf",
                ],
            )
            self.assertEqual(
                [(item.source.name, item.destination.name) for item in result.copied],
                [
                    ("AMaN_Chap08.pdf", "AMaN_Chap08_260619.pdf"),
                    ("AMaN_One.pdf", "AMaN_One_260619.pdf"),
                ],
            )
            self.assertEqual((destination / "AMaN_One_260619.pdf").read_bytes(), b"full")
            self.assertEqual(
                (destination / "AMaN_Chap08_260619.pdf").read_bytes(),
                b"chapter",
            )
            self.assertFalse((destination / "AMaN_One_260619_old.pdf").exists())
            self.assertFalse((destination / "AMaN_Chap08_260619_NK基本情况.pdf").exists())
            self.assertTrue((destination / "Other_Chap08_260619_NK.pdf").exists())

    def test_main_prints_readable_multiline_summary(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            tmp = Path(tmpdir)
            root = tmp / "repo"
            destination = tmp / "backup"
            root.mkdir()

            argv = [
                "backup_pdfs.py",
                "--root",
                str(root),
                "--destination",
                str(destination),
                "--prefix",
                "AMaN",
            ]

            result = backup_pdfs.BackupResult(
                removed=(
                    destination / "AMaN_Chap08_260619.pdf",
                    destination / "AMaN_Chap08_260619_NK基本情况.pdf",
                    destination / "AMaN_One_260619_old.pdf",
                ),
                copied=(
                    backup_pdfs.BackupCopy(
                        source=root / "900_PDF/03_Chapters/AMaN_Chap08.pdf",
                        destination=destination / "AMaN_Chap08_260619.pdf",
                    ),
                    backup_pdfs.BackupCopy(
                        source=root / "900_PDF/01_Full/AMaN_One.pdf",
                        destination=destination / "AMaN_One_260619.pdf",
                    ),
                ),
            )

            stdout = io.StringIO()
            with (
                patch.object(sys, "argv", argv),
                patch("backup_pdfs.backup_pdfs", return_value=result),
                redirect_stdout(stdout),
            ):
                exit_code = backup_pdfs.main()

            self.assertEqual(exit_code, 0)
            self.assertEqual(
                stdout.getvalue(),
                "\n".join(
                    [
                        "AMaN PDF backup completed",
                        f"  Root:        {root.resolve()}",
                        f"  Destination: {destination.resolve()}",
                        "  Removed:     3 old backup(s)",
                        "    - AMaN_Chap08_260619.pdf",
                        "    - AMaN_Chap08_260619_NK基本情况.pdf",
                        "    - AMaN_One_260619_old.pdf",
                        "  Copied:      2 PDF(s)",
                        "    - AMaN_Chap08.pdf -> AMaN_Chap08_260619.pdf",
                        "    - AMaN_One.pdf -> AMaN_One_260619.pdf",
                        "",
                    ]
                ),
            )


if __name__ == "__main__":
    unittest.main()
