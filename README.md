# SSH Codex Setup

发送一条 SSH 命令，让 Codex 帮你配置远程 Linux 节点和本机代理转发。

A Codex skill for setting up remote Linux nodes, SSH key authentication, and background reverse proxy tunnels from Windows.

## 能做什么

- 检查并配置 SSH 密钥登录。
- 让远程节点通过 SSH 反向转发使用本机 HTTP 代理（如 Clash）。
- 配置 Windows 后台任务：无需保持终端窗口，断线后自动重试。
- 检查远程 Codex 安装和登录状态，并测试模型连接。

## 安装

在 Codex 中发送：

```text
使用 skill-installer，从 https://github.com/zyliutj/ssh-codex-setup 安装 skills/setup-ssh-codex 技能。
```

安装后下一轮对话即可使用；如果未识别到技能，重启 Codex 再试。

## 使用

发送你的 SSH 命令即可，例如：

```text
ssh root@192.0.2.10 -p 2222
```

也可以明确指定技能：

```text
$setup-ssh-codex ssh root@192.0.2.10 -p 2222
```

将示例地址和端口替换为实际节点。默认用户名为 root，本机代理端口为 7897；其他代理端口或项目目录可以一起告诉 Codex。

## 使用前准备

- 本机安装 Windows OpenSSH 客户端和 Codex。
- 本机代理已启动；若服务器依赖校园或企业 VPN，请先连接 VPN。
- 拥有服务器的登录权限。密钥登录失败时，Codex 会询问当前节点的密码，并在工具支持时自动登录、安装公钥和继续配置；密码不写入文件或仓库。账号授权、验证码或受工具限制的桌面端操作仍需本人完成。

后台转发运行期间，本机、代理及所需 VPN 要保持在线。正常 SSH 连接与代理转发使用不同别名，减少端口争用。

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
