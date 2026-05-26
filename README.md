# XMU Advanced Macroeconomics II

厦门大学《高级宏观经济学 II》讲义项目，使用 XeLaTeX 维护完整讲义、分 Part 讲义和分 Chapter 讲义。仓库同时支持本地完整版和公开版构建：完整版保留后记、致谢等个人内容；公开版通过 `AMaN_Public.tex` 生成，不导入后记和致谢。

## 项目结构

```text
AMaN_Private.tex   完整版主文件；存在时 Makefile 优先使用它
AMaN_Public.tex    公开版主文件；仅在 AMaN_Private.tex 不存在时作为 fallback
AMaN_Two.tex       双面版主文件，会自动选择 AMaN_Private.tex 或 AMaN_Public.tex
Makefile           批量构建入口，会自动发现 full、part、chapter 正式 PDF

_asset/
  bib/             BibLaTeX 参考文献数据库
  figures/         正文图片与图形资源
  fonts/           仓库内置思源宋体、思源黑体及对应 OFL 许可证
  scripts/         辅助生成图形或数值结果的脚本

_config/           导言区拆分配置；build-structure.tex 由 Makefile 自动生成
100_FrontMatter/   封面、献词、前言、说明、凡例
200_MainMatter/    正文内容，按 Partxx/Chapxx 自动发现
300_BackMatter/    日志、后记、致谢、附录等后置内容
900_PDF/           正式 PDF 输出目录
```

`200_MainMatter/Partxx/` 中可以同时有 Part 入口、Part 封面和章节文件：

```text
200_MainMatter/Part02/Part02.tex   Part 02 汇总入口
200_MainMatter/Part02/Chap04.tex   Chapter 04 正文
200_MainMatter/Part02/PartCover02.tex  Part 02 封面内容，不单独编译
```

批量构建以 `Makefile` 的自动发现为准：新增 `200_MainMatter/Part04/Chap11.tex` 后，`make chapters` 会自动加入 `AMaN_Chap11.pdf`，`make parts` 会自动加入 `AMaN_Part04.pdf`。如果 `Part04.tex` 不存在，`make` 会生成一个入口文件；如果存在 `PartCover04.tex`，它会被自动纳入 Part 04。

已有 `Chapxx.tex` 和 `Partxx.tex` 仍可作为 LaTeX Workshop 的当前项目编译。新章节如果只写正文、不写独立编译头，也可以直接用 `make chapxx` 构建。

## 构建环境

需要本地安装：

- GNU Make
- XeLaTeX
- `latexmk`
- `biber`

中文字体默认优先读取 `_asset/fonts/` 中的思源字体；如果这些文件不存在，则回退到系统字体名 `Source Han Serif SC` 和 `Source Han Sans SC`。楷体使用 TeX Live 自带的 `FandolKai-Regular.otf`，英文字体和数学字体使用 TeX Gyre Pagella。

## 构建命令

构建全部 PDF：

```bash
make all
```

常用目标：

```bash
make full      # AMaN_One.pdf 和 AMaN_Two.pdf
make parts     # 自动发现所有 Partxx
make chapters  # 自动发现所有 Chapxx
make chap03    # 单独构建 Chapter 03
make part03    # 单独构建 Part 03
make list      # 列出当前发现的 Part 和 Chapter
make clean     # 清理 LaTeX 辅助文件
make distclean # 清理辅助文件和生成的 PDF
```

`Makefile` 是正式 PDF 的批量产出入口。它会先刷新 `_config/build-structure.tex`，必要时创建缺失的 `Partxx.tex`，再在临时目录中运行 `latexmk`，最后只把 PDF 复制到 `900_PDF/`。`make` 不负责保留 `.aux` 或 SyncTeX；需要 `.aux`、`.synctex.gz` 和本地预览 PDF 时，直接在 `200_MainMatter/` 中用 LaTeX Workshop Build。

备份默认不随 `make all` 执行。需要备份时显式传入目标目录：

```bash
make backup BACKUP_DESTINATION="/path/to/backup"
make all BACKUP=1 BACKUP_DESTINATION="/path/to/backup"
```

## PDF 输出

正式输出位于 `900_PDF/`：

```text
900_PDF/01_Full/AMaN_One.pdf
900_PDF/01_Full/AMaN_Two.pdf
900_PDF/02_Parts/AMaN_Part01.pdf
900_PDF/02_Parts/AMaN_Part02.pdf
...
900_PDF/03_Chapters/AMaN_Chap01.pdf
...
900_PDF/03_Chapters/AMaN_Chap10.pdf
```

命名规则为 `AMaN_One`、`AMaN_Two`、`AMaN_Partxx`、`AMaN_Chapxx`。目录用数字前缀保持排序：full 在 part 上方，part 在 chapter 上方。

## VS Code

仓库包含 `.vscode/settings.json`，用于区分日常写作和批量构建：

日常写作时，在 `200_MainMatter/Partxx/Chapxx.tex` 或 `200_MainMatter/Partxx/Partxx.tex` 中使用 LaTeX Workshop 的 Build LaTeX project。插件会直接用 `latexmk -xelatex` 编译当前文件，并把同名 `.aux`、`.pdf` 与 `.synctex.gz` 留在文件旁边，便于 View LaTeX PDF File 和 PDF 反向跳转到源码。自动清理不会删除 `.aux`。

批量更新正式讲义时，使用 `make all`、`make parts`、`make chapters` 等命令。`make` 输出到 `900_PDF/`，不会在 `900_PDF/` 或源码目录中留下 `.aux`、SyncTeX 或其他中间构建文件。

## 字体许可

`_asset/fonts/` 中的思源宋体和思源黑体文件来自 Adobe Source Han 字体项目，按 SIL Open Font License 1.1 发布。仓库保留对应的许可证文本：

```text
_asset/fonts/LICENSE-SourceHanSerif.txt
_asset/fonts/LICENSE-SourceHanSans.txt
```

未修改的字体文件可以随项目再分发，但字体文件本身不能单独出售；如果未来修改字体文件，需要遵守许可证中关于 Reserved Font Name 的限制。

## 授权

本仓库根目录包含 `LICENSE`。根据前言和说明中的署名、非商业使用要求，除另有注明外，笔记正文、LaTeX 源文件、自制图表和生成 PDF 使用 Creative Commons Attribution-NonCommercial 4.0 International（CC BY-NC 4.0）授权。

第三方课程材料、引用文献、论文、摘录内容和其他第三方内容保留其原始权利。`_asset/fonts/` 中的字体文件不适用 CC BY-NC 4.0，而是分别适用目录内保留的 SIL Open Font License 1.1 文本。
