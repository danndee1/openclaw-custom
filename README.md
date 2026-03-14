# openclaw-custom

基于上游 `1186258278/openclaw-zh:nightly` 的包装镜像模板。  
目标：你可以持续跟进上游更新，同时保留自己的运行环境约束和持久化目录。

## 文件说明

- `Dockerfile`: 在上游镜像基础上补齐 Python/常用工具。
- `requirements.extra.txt`: 固定安装的 Python 依赖清单。
- `.github/workflows/build-and-push.yml`: 自动构建并推送到 GHCR。
- `docker-compose.custom.yml`: 生产部署示例（含缓存/模型/本地配置挂载）。

## 一次性准备

1. 创建 GitHub 仓库（例如：`openclaw-custom`），把本目录文件推上去。
2. 确保仓库 Actions 可用，并且包权限允许写入 GHCR。
3. 把 `docker-compose.custom.yml` 里的 `YOUR_GH_USERNAME` 替换成你的 GitHub 用户名或组织名。

## 自动构建

工作流会在以下时机触发：

- 手动触发（`workflow_dispatch`）
- 每 6 小时轮询一次上游
- 你改 `Dockerfile` 或 `requirements.extra.txt` 后 push

产物标签：

- `ghcr.io/<owner>/openclaw-custom:latest`
- `ghcr.io/<owner>/openclaw-custom:upstream-<digest前12位>`

## 服务器部署步骤

在你的服务器（1Panel 主机）执行：

```bash
mkdir -p /opt/1panel/docker/compose/openclaw/persist/cache
mkdir -p /opt/1panel/docker/compose/openclaw/persist/models
mkdir -p /opt/1panel/docker/compose/openclaw/persist/config
mkdir -p /opt/1panel/docker/compose/openclaw/persist/local
# 如要保留 /tmp 缓存，再创建:
# mkdir -p /opt/1panel/docker/compose/openclaw/persist/tmp
```

将 `docker-compose.custom.yml` 内容合并到你当前的 compose，或直接替换 `openclaw` 服务。  
然后更新：

```bash
cd /opt/1panel/docker/compose/openclaw
docker compose pull openclaw
docker compose up -d openclaw
```

## 升级策略建议

1. 日常用 `latest` 自动跟上游。
2. 发现问题时，回滚到某个 `upstream-xxxx` 稳定标签。
3. 不要在容器内手工 `apt install` 当作长期方案，系统依赖要写入 `Dockerfile`。

## 目录持久化建议

- `/root/.openclaw`: OpenClaw 主数据（你已在用）。
- `/root/.cache`: pip/huggingface/torch 等缓存。
- `/models`: 本地模型文件。
- `/root/.config`: 如 Notion API key（例如 `/root/.config/notion/api_key`）。
- `/root/.local`: 如 `skillhub`、npm 全局工具等用户态安装内容。
- `/tmp`：仅在你确实要保留运行时缓存时才挂载。

## venv 注意事项

为避免解释器路径变化导致 venv 失效，重建 venv 时推荐：

```bash
python3 -m venv --copies /root/.openclaw/venvs/<name>
```

这样不会用绝对软链接绑定到旧镜像解释器路径。
