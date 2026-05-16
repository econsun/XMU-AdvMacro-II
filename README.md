# XMU Advanced Macroeconomics II

厦门大学《高级宏观经济学 II》讲义项目，使用 XeLaTeX 维护完整讲义、分 Part 讲义和分 Chapter 讲义。仓库同时支持本地完整版和公开版构建：完整版保留后记、致谢等个人内容；公开版通过 `AMaN_Public.tex` 生成，不导入后记和致谢。

## 项目结构

```text
AMaN.tex           完整版主文件；存在时 Makefile 优先使用它
AMaN_Public.tex    公开版主文件；仅在 AMaN.tex 不存在时作为 fallback
Makefile           统一构建入口，负责 full、part、chapter 和 VS Code 构建映射

_asset/
  bib/             BibLaTeX 参考文献数据库
  figures/         正文图片与图形资源
  fonts/           仓库内置思源宋体、思源黑体及对应 OFL 许可证
  scripts/         辅助生成图形或数值结果的脚本

_config/           导言区拆分配置：字体、版式、编号、颜色、超链接、定理盒等
100_FrontMatter/   封面、献词、前言、说明、凡例
200_MainMatter/    正文内容，按 Part01、Part02、Part03 排列
300_BackMatter/    日志、后记、致谢、附录等后置内容
900_Entries/       供 latexmk 调用的 full、part、chapter 编译入口
900_PDF/           正式 PDF 输出目录
```

`900_Entries` 中的入口文件会自动判断主文件：如果根目录存在 `AMaN.tex`，则编译完整版本；如果不存在，则编译 `AMaN_Public.tex`。因此公开仓库可以只保留 `AMaN_Public.tex` 和它引用到的内容。

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
make parts     # AMaN_Part01.pdf 到 AMaN_Part03.pdf
make chapters  # AMaN_Chap01.pdf 到 AMaN_Chap08.pdf
make chap03    # 单独构建 Chapter 03
make clean     # 清理 LaTeX 辅助文件
make distclean # 清理辅助文件和生成的 PDF
```

`Makefile` 会在临时目录中运行 `latexmk`，然后把正式 PDF 复制到 `900_PDF/`。这样源码目录不会残留 `.aux`、`.log`、`.bcf`、`.synctex.gz` 等辅助文件。

## PDF 输出

正式输出位于 `900_PDF/`：

```text
900_PDF/01_Full/AMaN_One.pdf
900_PDF/01_Full/AMaN_Two.pdf
900_PDF/02_Parts/AMaN_Part01.pdf
900_PDF/02_Parts/AMaN_Part02.pdf
900_PDF/02_Parts/AMaN_Part03.pdf
900_PDF/03_Chapters/AMaN_Chap01.pdf
...
900_PDF/03_Chapters/AMaN_Chap08.pdf
```

命名规则为 `AMaN_One`、`AMaN_Two`、`AMaN_Partxx`、`AMaN_Chapxx`。目录用数字前缀保持排序：full 在 part 上方，part 在 chapter 上方。

## VS Code

仓库包含 `.vscode/settings.json`，LaTeX Workshop 保存文件时会调用：

```bash
make vscode DOC=<current-file>
```

`Makefile` 会根据当前文件自动映射到对应的 full、part 或 chapter PDF。例如保存 `200_MainMatter/Part02/Chap04.tex` 时，会构建 `900_PDF/03_Chapters/AMaN_Chap04.pdf`。

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
