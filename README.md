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
bash -c 'set -o pipefail; curl -fsSL https://raw.githubusercontent.com/madiks/gogo-releases/main/install.sh | GOGO_VERSION=v0.1.1 bash'
```

也可以先[查看安装脚本](./install.sh)，确认后再运行。安装脚本会下载对应平台的 Release 压缩包，校验 SHA256 和版本，再替换本地二进制。下载或校验失败时，已有安装不会被覆盖。

安装完成后验证：

```bash
gogo -version
```

## 快速开始

升级当前安装的 GoGo 到最新正式版本：

```bash
gogo -upgrade
```

升级会校验 SHA256 和版本后替换当前可执行文件，保留配置、密钥和会话。下载或校验失败时保留旧程序。

卸载当前安装的 GoGo：

```bash
gogo -uninstall
```

此命令删除当前运行的可执行文件，保留 `~/.gogo/` 中的配置、密钥和会话。

在希望 GoGo 操作的项目目录中启动：

```bash
cd /path/to/your/project
gogo
```

### 配置 Provider

在 GoGo 输入框中输入 `/provider` 并按 Enter：

1. 选择“添加 Provider”，选择供应商预设；使用兼容服务时选择“手动配置 Provider”，再选择相应协议。
2. 填写 Provider ID、Base URL 和 API Key。预设会提供默认地址，使用自建服务或代理时填写其服务地址。
3. 用 Tab 切换字段，按 Enter 保存并获取模型列表。完成后按 Esc 返回输入框。

GoGo 支持 OpenAI Responses、OpenAI Chat Completions 和 Anthropic Messages 协议。服务地址与协议须匹配；如果获取模型失败，检查地址、密钥和网络。通过 `/provider` 选中已配置的 Provider 后，按 `r` 可刷新模型列表，按 Enter 可重新配置。

### 选择默认模型

在刚启动的欢迎页、发送第一条消息之前，输入 `/model`，搜索并选择模型，再按 Enter。此时选择会保存为默认模型，供后续新会话使用。

**已有会话中执行 `/model` 只切换当前会话的模型。** 要设置全局默认模型，可以退出后重新运行 `gogo`，在欢迎页选择；也可以编辑 `~/.gogo/config.json` 的 `defaultModel` 字段：

```json
{
  "defaultModel": {
    "providerId": "your-provider-id",
    "modelId": "your-model-id"
  }
}
```

将示例中的 ID 替换成已配置的 Provider 和模型 ID。编辑已有配置时保留其他字段；文件修改后执行 `/reload` 或重新启动 GoGo。

### 提交任务

选择模型后，直接输入任务并按 Enter，例如“查看这个项目的结构，解释主要模块”。也可以在终端中运行一次性任务：

```bash
gogo -p "查看这个项目的结构，解释主要模块"
```

| 命令 | 用途 |
| --- | --- |
| `/help` | 查看命令说明 |
| `/provider` | 配置 Provider、刷新模型列表 |
| `/model` | 选择默认模型或切换当前会话模型 |
| `/new` | 开始新会话 |
| `/resume` | 选择历史会话继续工作 |
| `/language` | 切换中文或英文 |
| `/reload` | 重新加载配置 |
| `/quit` | 退出 GoGo |

配置保存在 `~/.gogo/`：`models.json` 保存 Provider 与模型列表，`auth.json` 保存 API Key，`config.json` 保存默认模型等设置。请勿将凭据文件或真实 API Key 上传到反馈中。GoGo 可以调用工具读取、修改文件和执行命令，请在你信任的项目目录中使用。

## 下载与反馈

- [查看 Releases](https://github.com/madiks/gogo-releases/releases)
- [提交安装或使用反馈](https://github.com/madiks/gogo-releases/issues/new)

公开的 Release 二进制可由任何人下载。此仓库的源码归档只包含分发文档和安装脚本，不包含 GoGo 应用源码。
