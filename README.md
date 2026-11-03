# dytescn.github.io

dytescn 官方主页源码。

- 线上地址：https://www.dytes.cn
- GitHub 组织：https://github.com/dytescn
- 产品入口：https://github.com/dytescn/dytes

## 目录

```text
index.html          # 首页
404.html            # 404 页面
assets/css/site.css # 样式
assets/js/site.js   # 下载面板、复制、版本同步
install.sh          # macOS / Linux 安装脚本
install.ps1         # Windows 安装脚本
CNAME               # www.dytes.cn
```

## 本地预览

```bash
deno task view
```

也可以使用任意静态文件服务器，例如：

```bash
python -m http.server 8765
```

## 部署

推送到 `main` 后，在仓库设置：

```text
Settings → Pages
→ Deploy from a branch
→ Branch: main
→ Folder: / (root)
→ Save
```

自定义域名：

```text
Custom domain: www.dytes.cn
```

DNS：

```text
www.dytes.cn  CNAME  dytescn.github.io
```

## 版本同步与下载源

- 下载源：`https://packages.funxdata.com/core/dytes/latest/<platform>/`
- 版本信息（运行时）：
  - 首页加载 `https://packages.funxdata.com/core/dytes/latest/version.js`，
    由 `dytes` release workflow 在发布时生成；
  - 同时读取本仓库 `assets/data/release.json`，两者取较高版本，
    避免 CDN 缓存导致页面回退到旧版本；
- 版本同步（发布后）：`dytes` 发布 workflow 在自检通过后向本仓库发送
  `repository_dispatch`（`dytes-release`），由
  [`.github/workflows/sync-release.yml`](.github/workflows/sync-release.yml)
  更新 `assets/data/release.json` 并提交，触发 Pages 重新部署；
- 自动同步需要在 `dytescn/dytes` 仓库配置 secret `WEBSITE_DISPATCH_TOKEN`
  （具备本仓库 contents 写权限的 fine-grained PAT）。未配置时仍可在
  Actions 中手动运行 **Sync dytes release**；
- 安装脚本：`install.sh` / `install.ps1` 从 packages 域名下载，并校验同名 `.sha256`；
- 不再使用 GitHub Release 作为二进制下载源。

`dytes` 每次发布后需检查上述地址与官网三个平台下载按钮，清单见
`dytes_sys_operations/sysinfo/app/publish.md` §6.1。
