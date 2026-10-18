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
```

以上内容是发给 Codex 的消息，不是在 PowerShell 中执行的命令。示例地址仅用于说明，请替换为实际节点。

安装后下一轮对话即可使用；如果未识别到技能，重启 Codex 再试。不要直接删除正在使用的技能目录。

后续新增节点只需发送 SSH 命令，无需提供项目目录。桌面会话验收已内置在技能中，不需要用户重复要求。

## 使用前准备

- 本机安装 Windows OpenSSH 客户端和 Codex。
- 本机代理已启动；若服务器依赖校园或企业 VPN，请先连接 VPN。
- 拥有服务器的登录权限。密钥登录失败时，Codex 会询问当前节点的密码，并在工具支持时自动登录、安装公钥和继续配置；密码不写入文件或仓库。账号授权、验证码或受工具限制的桌面端操作仍需本人完成。

后台转发运行期间，本机、代理及所需 VPN 要保持在线。正常 SSH 连接与代理转发使用不同别名，减少端口争用。

## 过程中可能需要你做什么

1. **提供服务器密码**：已有密钥无法登录时，Codex 会询问当前节点的密码，用于首次登录和自动安装公钥。不要把密码写进 README、SSH 命令或提交到 GitHub；普通聊天不是专用秘密输入渠道。
2. **完成 Codex 账号授权**：节点尚未登录时，Codex 会提供官方授权链接和一次性验证码。你需要在浏览器中登录自己的账号并完成授权，然后告诉 Codex“已授权”，继续配置和测试。
3. **必要的桌面操作**：若当前工具无法代选远程主机或打开会话，按提示在 Codex 桌面端操作。无需提供业务项目目录。

## 完成标准

Codex 负责验证目标节点的桌面会话正常完成并返回 `CONNECTION_OK`。仅 SSH 登录、后台任务或 CLI 成功都不能替代桌面验收；失败时继续排查，遇到授权或工具限制时明确说明未完成的步骤。

## 代理自动识别

由 Codex 按技能流程检查系统代理、环境变量和代理进程的实际监听端口，实测后选择 HTTP/mixed 入口，不固定为 7897。只有 PAC/TUN/SOCKS、需要认证或多个候选无法确定时，会说明情况并询问。

换电脑时重新识别。已创建的后台任务不会自动跟随代理端口变化；端口变化后重新运行技能更新配置。

## 项目结构

```text
skills/setup-ssh-codex/
├── SKILL.md                 # Codex 操作流程
├── agents/openai.yaml       # 技能名称与识别设置
└── scripts/keep-tunnel.ps1   # 后台转发与断线重试
```

本项目不保存密码、私钥或登录令牌。它是供 Codex 使用的技能，不是独立的一键安装软件。
