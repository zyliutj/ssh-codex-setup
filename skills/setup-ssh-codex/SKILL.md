---
name: setup-ssh-codex
description: Configure Linux SSH nodes for Windows Codex desktop and a local HTTP reverse proxy. Trigger when the user supplies an SSH command to onboard or reconfigure a node, or asks to repair that node's Codex connection. Do not treat quoted SSH commands in unrelated explanations as onboarding requests.
---

# SSH 节点接入 Codex

用户希望只发送 `ssh root@地址 -p 端口` 就能完成节点接入。默认用户名 root；省略端口时 SSH 默认 22。使用中文沟通。正常自动选择此技能，无需用户每次显式指定。

## 输入与本机约定

- 把命令当作待解析数据，不执行整段用户字符串。提取 host、user、port；拒绝夹带的 shell 命令、未知选项，必要时澄清。端口必须为 1–65535。
- 默认本机代理为 `127.0.0.1:7897`、远端入口为 `127.0.0.1:17890`；先实测端口，不凭默认值宣称可用。
- 本机为 Windows；个人 SSH 配置为 `$env:USERPROFILE\.ssh\config`。读取已有配置和密钥文件名，绝不输出私钥内容或认证令牌。
- 优先复用用户 SSH 配置中适用于目标的密钥，检查是否已被新节点接受。没有可用密钥时再生成专用密钥并安装公钥。不可把历史聊天里的密码当新节点通用密码，也不保存密码。
- 从用户请求、已有项目绑定或目标主目录确定项目候选；先检查存在性，多个候选无法确定时询问。

## 范围与预检

用户发送节点接入命令授权配置该节点所需的 SSH 条目、专用后台转发、远端 Codex 启动环境及最小测试；不授权停止训练、推送代码、迁移会话或更改无关节点。先检查已有状态，复用正确配置。查询当前官方 Codex 文档时使用可用的 openai-docs 技能，不硬编码未来版本的安装方法、UI 菜单或 CLI 参数。

1. 读取 SSH 配置、`ssh -G` 有效配置、Clash 监听、到目标的连通性。校园内网地址依赖校园 VPN；不可自动关闭/修改 VPN 或 Clash 全局路由。
2. 用 BatchMode 与连接超时测试现有密钥。首次主机密钥可按正常首次连接流程处理；已知主机指纹变化必须核实，不能删除 known_hosts 或关闭验证来掩盖。
3. 用户名固定 root，但不得假设旧节点同 IP 新端口就是相同服务器。用 hostname、实际端口及文件检查辨别；同一 IP 不同端口同时使用时分配不同别名，避免覆盖现有项目绑定。若明确替换旧端口，备份并更新对应条目。
4. 检查远端 `~/.local/bin/codex`、PATH、版本、login status、现有代理启动器。非交互 shell 找不到 codex 时先试绝对路径，不能误判未安装。不要复制另一节点 auth.json；已有登录可验证后复用。

## 独立反向转发：关键约束

普通桌面/VS Code SSH 别名只负责登录；另建稳定的专用转发别名（名称含 host 与 port），只有专用别名包含：

```sshconfig
RemoteForward 127.0.0.1:17890 127.0.0.1:7897
ExitOnForwardFailure yes
ServerAliveInterval 30
ServerAliveCountMax 3
```

两条别名使用同样 HostName、User、Port、IdentityFile、IdentitiesOnly yes。普通别名也设置 keepalive，但不重复申请 RemoteForward。检查 Host *、Include 等继承项，防止普通别名仍继承转发。需要时对普通别名设置 ClearAllForwardings yes，但先确认没有其他用户需要的转发。

配置改动使用最小补丁，修改前建立明确命名的备份。远端端口仅监听回环地址。不同服务器可以使用同一远端端口；同一服务器上的多个连接不能争占同一个监听入口。端口被占用时先检查现有转发是否健康及归属，不能盲目杀 sshd 或所有 SSH 进程。

后台运行使用随技能提供的 `scripts/keep-tunnel.ps1`。安装时将脚本放入稳定的用户目录，创建每节点一个 Windows 计划任务，动作使用 powershell.exe 的 `-NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File` 和 `-Alias` 参数。不要用用户 SSH 原始字符串构造命令。

任务配置：当前用户 Interactive、Limited；登录触发；IgnoreNew；ExecutionTimeLimit=0；允许电池运行；StartWhenAvailable；RestartCount=999、RestartInterval=1 分钟。不要对同名且不属于本技能的任务直接覆盖。保留后续可维护的任务名、脚本路径及日志位置。启动后验证真正的 ssh 子进程和远端端口，Running 状态本身不够。

脚本循环负责 SSH 退出后重试，计划任务负责脚本异常退出后恢复。任务被手动停止/禁用、用户注销、电脑关机时不能保证自动恢复；不能宣称绝不会断线。保持 Clash 与校园 VPN 可用。一次诊断内最多重启已识别的专用任务两次；仍失败则报告证据，避免无休止改配置。

## 服务器 Codex

- 保留已有健康安装。需要安装时用当前官方支持方式，不默认服务器有 npm 或 sudo。
- 让桌面端启动的 Codex 进程继承 HTTP_PROXY/HTTPS_PROXY/http_proxy/https_proxy=`http://127.0.0.1:17890`，NO_PROXY/no_proxy=`localhost,127.0.0.1,::1`。只在手动终端 export 不足以覆盖桌面 app-server。
- 优先最小修改现有用户启动器。新建包装器时记录真实二进制路径，防止调用自己形成递归；不要硬编码易随 VS Code 扩展升级消失的版本路径。若现有启动器动态查找扩展二进制，验证其可执行文件再复用。
- 已运行 app-server 不会自动获得新环境变量。确需重启时辨认节点、用户、PID、活跃会话，避免干扰训练或其他会话；优先受支持的重连流程。未经检查不能 pkill codex。
- 缺少登录时引导用户完成 device auth，不代填认证弹窗，不把设备码/令牌写进长期文档。授权完成后继续验证，不重复申请授权。

## 桌面接入与验收

使用可用的 list_projects/list_threads 等产品工具确认主机是否已被发现及项目绑定。工具无添加主机能力时说明只剩用户在桌面选择普通 SSH 别名及项目目录，不得声称桌面已接入。遵守当前 UI 自动化限制，不绕过限制编辑应用私有状态数据库。专用转发别名不应被选为工作主机。

分层验证并分别报告：

1. SSH：BatchMode 登录、hostname。
2. 代理：通过远端回环代理请求服务。HTTP 401（无认证探针）只代表服务可达，不代表账号有效；Cloudflare 403 也不等于账号地区错误。
3. 模型：按当前 CLI 支持的方式运行一次 ephemeral、read-only、无工具的 CONNECTION_OK 请求；限制运行时间，不触碰项目。
4. 桌面：检查目标 hostId 下真实会话的回复和工具执行。仅获授权测试会话时向对应会话发送只读 hostname/git branch 请求；已有正在运行的工作先等候，不随意打断。没有授权新建会话则不创建新会话；没有可测会话时交代未验证部分。

最终给出 host/port、普通 SSH 别名、后台任务、项目目录、测试结果及剩余手动步骤；不输出密码。停止/禁用说明必须针对确切任务，不影响其他节点。仅真实模型响应且桌面会话验证通过，才说“桌面端正常可用”。

## 排障证据

- 曾发生多个 SSH 同时断线，重连时报 `remote port forwarding failed for listen port 17890`，而 SSH 仍能登录。应检查监听归属和有效配置，不能直接认定账号或训练程序问题。
- 计划任务曾返回 `0xC000013A` 并退出：这说明进程被中断，不能据此断定用户或某应用是原因。检查任务历史及进程再恢复，并确认异常重启设置。
- 读日志应限量 tail 字节并清除 NUL，避免稀疏日志或巨长行淹没上下文。使用不含 RemoteForward 的普通别名做诊断，避免诊断连接临时建立代理导致假阳性。
- 同一会话 ID 可能因克隆目录出现在多个节点；始终带目标 hostId，不能只按标题或 ID 判断。
