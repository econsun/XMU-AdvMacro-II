# XMU Advanced Macroeconomics II

厦门大学高级宏观经济学 II 讲义项目，使用 XeLaTeX 维护完整讲义、分 Part 讲义和分 Chapter 讲义。

## Repository Layout

```text
00_Config/        LaTeX 宏包、版式、字体、编号和超链接配置
10_FrontMatter/   封面、前言、说明、凡例等前置内容
20_MainMatter/    正文内容，按 Part 和 Chapter 排列
90_BackMatter/    日志、后记、致谢和附录
95_Entries/       单独编译入口
99_PDF/           生成后的 PDF 文件
AMaN.tex          主文档入口
Makefile          统一构建脚本
```

## Build

需要本地安装 `latexmk`、XeLaTeX 和 GNU Make。

构建全部 PDF：

```bash
make all
```

常用构建目标：

```bash
make full      # AMaN_One.pdf 和 AMaN_Two.pdf
make parts     # AMaN_Part01.pdf 到 AMaN_Part03.pdf
make chapters  # AMaN_Chap01.pdf 到 AMaN_Chap08.pdf
make chap03    # 单独构建 Chapter 03
make clean     # 清理 LaTeX 辅助文件
```

## PDF Naming

正式输出位于 `99_PDF/`：

```text
99_PDF/01_Full/AMaN_One.pdf
99_PDF/01_Full/AMaN_Two.pdf
99_PDF/02_Parts/AMaN_Part01.pdf
99_PDF/02_Parts/AMaN_Part02.pdf
99_PDF/02_Parts/AMaN_Part03.pdf
99_PDF/03_Chapters/AMaN_Chap01.pdf
...
99_PDF/03_Chapters/AMaN_Chap08.pdf
```

## VS Code

仓库包含 `.vscode/settings.json`，LaTeX Workshop 保存文件时会调用：

```bash
make vscode DOC=<current-file>
```

`Makefile` 会根据当前文件自动映射到对应的 full、part 或 chapter PDF。
