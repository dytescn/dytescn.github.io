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

## 版本同步

首页通过 GitHub API 读取 `dytescn/dytes` 的最新 Release，并显示版本号与 Release 链接。
