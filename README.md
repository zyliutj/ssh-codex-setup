# SSH Codex Setup

发送一条 SSH 命令，让 Codex 帮你配置远程 Linux 节点和本机代理转发。

A Codex skill for setting up remote Linux nodes, SSH key authentication, and background reverse proxy tunnels from Windows.

## 能做什么

- 检查并配置 SSH 密钥登录。
- 让远程节点通过 SSH 反向转发使用本机 HTTP 代理（如 Clash）。
- 配置 Windows 后台任务：无需保持终端窗口，断线后自动重试。
- 检查远程 Codex 安装和登录状态，以桌面端会话成功收到回复为最终验收；不依赖任何业务项目或 Git 仓库。

## 安装并配置节点

在 Codex 中复制发送下面这段话，将 SSH 地址和端口换成你自己的：

```text
使用 skill-installer，从 https://github.com/zyliutj/ssh-codex-setup 安装 skills/setup-ssh-codex 技能。
ssh命令是：ssh root@10.210.22.122 -p 31242
请完成节点配置，最后一定要验证能够顺利在 Codex 桌面端进行会话。
```

以上内容是发给 Codex 的消息，不是在 PowerShell 中执行的命令。示例地址仅用于说明，请替换为实际节点。

安装后下一轮对话即可使用；如果未识别到技能，重启 Codex 再试。已有同名技能时，请按下方“更新”说明处理，不要直接删除正在使用的技能目录。

## 使用

已安装技能后，后续新增节点只需发送：

```text
ssh命令是：ssh root@10.210.22.122 -p 31242
```

也可以明确指定技能：

```text
$setup-ssh-codex ssh root@10.210.22.122 -p 31242
```

将示例地址和端口替换为实际节点。默认用户名为 root，本机代理端口为 7897；如使用其他代理端口，一起告诉 Codex 即可。无需提供项目目录。

## 使用前准备

- 本机安装 Windows OpenSSH 客户端和 Codex。
- 本机代理已启动；若服务器依赖校园或企业 VPN，请先连接 VPN。
- 拥有服务器的登录权限。密钥登录失败时，Codex 会询问当前节点的密码，并在工具支持时自动登录、安装公钥和继续配置；密码不写入文件或仓库。账号授权、验证码或受工具限制的桌面端操作仍需本人完成。

后台转发运行期间，本机、代理及所需 VPN 要保持在线。正常 SSH 连接与代理转发使用不同别名，减少端口争用。

## 过程中可能需要你做什么

1. **提供服务器密码**：已有密钥无法登录时，Codex 会询问当前节点的密码，用于首次登录和自动安装公钥。不要把密码写进 README、SSH 命令或提交到 GitHub；普通聊天不是专用秘密输入渠道。
2. **完成 Codex 账号授权**：节点尚未登录时，Codex 会提供官方授权链接和一次性验证码。你需要在浏览器中登录自己的账号并完成授权，然后告诉 Codex“已授权”，继续配置和测试。
3. **必要的桌面操作**：若当前工具无法代选远程主机或打开会话，按提示在 Codex 桌面端操作。无需提供业务项目目录。

## 最后必须验证桌面会话

在目标节点的 Codex 桌面会话中发送：

```text
请只回复 CONNECTION_OK，不使用工具或访问文件。
```

确认该轮会话正常完成并收到 `CONNECTION_OK`，才算接入成功。仅 SSH 登录成功、后台任务正在运行或服务器 CLI 测试成功，都不能替代这一步。如果失败，应继续排查并修复；若受账号授权或工具限制阻塞，必须明确说明尚未完成桌面会话验收。

## 更新

技能安装到本地后运行，**不会自动同步 GitHub 更新**。更新时对 Codex 说：

```text
请从 zyliutj/ssh-codex-setup 更新 setup-ssh-codex 技能，先比较并备份现有版本，保留正在使用的后台任务。
```

## 项目结构

```text
skills/setup-ssh-codex/
├── SKILL.md                 # Codex 操作流程
├── agents/openai.yaml       # 技能名称与识别设置
└── scripts/keep-tunnel.ps1   # 后台转发与断线重试
```

本项目不保存密码、私钥或登录令牌。它是供 Codex 使用的技能，不是独立的一键安装软件。
