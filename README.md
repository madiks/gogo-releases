# GoGo

GoGo 是一款面向开发者的 Coding Agent。此仓库专门分发二进制、提供安装入口并收集使用反馈；GoGo 源码目前保存在独立的私有仓库，后续开源仍与此发布仓库分开维护。

## 安装与升级

支持 macOS 和 Linux，`arm64` 与 `amd64` 架构。安装最新正式版本：

```bash
bash -c 'set -o pipefail; curl -fsSL https://raw.githubusercontent.com/madiks/gogo-releases/main/install.sh | bash'
```

重复运行即可升级到最新正式版本。安装位置默认为 `~/.local/bin/gogo`，不需要 `sudo`，也不会改动 `~/.gogo` 中的配置和会话。如果该目录尚未加入 `PATH`，安装脚本会提示如何设置。

安装指定版本，包括预发布版本：

```bash
bash -c 'set -o pipefail; curl -fsSL https://raw.githubusercontent.com/madiks/gogo-releases/main/install.sh | GOGO_VERSION=v0.1.0 bash'
```

也可以先[查看安装脚本](./install.sh)，确认后再运行。安装脚本会下载对应平台的 Release 压缩包，校验 SHA256 和版本，再替换本地二进制。下载或校验失败时，已有安装不会被覆盖。

安装完成后验证：

```bash
gogo -version
```

## 下载与反馈

- [查看 Releases](https://github.com/madiks/gogo-releases/releases)
- [提交安装或使用反馈](https://github.com/madiks/gogo-releases/issues/new)

公开的 Release 二进制可由任何人下载。此仓库的源码归档只包含分发文档和安装脚本，不包含 GoGo 应用源码。
