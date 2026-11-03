const commands = {
  unix: "curl -fsSL https://www.dytes.cn/install.sh | sh",
  windows: "irm https://www.dytes.cn/install.ps1 | iex",
};

const hints = {
  unix: "安装到 ~/.local/bin",
  windows: "安装到 %LOCALAPPDATA%\\dytes\\bin",
};

let activeTab = "unix";

const tabs = document.querySelectorAll("[data-tab]");
const codeBlocks = document.querySelectorAll("[data-command]");
const copyButton = document.querySelector("[data-copy]");
const installHint = document.querySelector("[data-install-hint]");

function showTab(tab) {
  activeTab = tab;

  tabs.forEach((button) => {
    button.setAttribute("aria-selected", String(button.dataset.tab === tab));
  });

  codeBlocks.forEach((block) => {
    block.hidden = block.dataset.command !== tab;
  });

  if (installHint) {
    installHint.textContent = hints[tab] || "";
  }

  if (copyButton) {
    copyButton.textContent = "复制";
  }
}

tabs.forEach((button) => {
  button.addEventListener("click", () => showTab(button.dataset.tab));
});

async function copyText(text) {
  if (navigator.clipboard && window.isSecureContext) {
    await navigator.clipboard.writeText(text);
    return;
  }

  const textarea = document.createElement("textarea");
  textarea.value = text;
  textarea.style.position = "fixed";
  textarea.style.opacity = "0";
  document.body.appendChild(textarea);
  textarea.select();
  document.execCommand("copy");
  textarea.remove();
}

if (copyButton) {
  copyButton.addEventListener("click", async () => {
    try {
      await copyText(commands[activeTab]);
      copyButton.textContent = "已复制";
      window.setTimeout(() => {
        copyButton.textContent = "复制";
      }, 1600);
    } catch {
      copyButton.textContent = "复制失败";
    }
  });
}

function parseVersion(value) {
  const match = /^(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?$/.exec(
    String(value || "").replace(/^v/, ""),
  );
  if (!match) {
    return null;
  }
  return {
    major: Number(match[1]),
    minor: Number(match[2]),
    patch: Number(match[3]),
    pre: match[4] || "",
  };
}

function compareVersions(a, b) {
  const left = parseVersion(a);
  const right = parseVersion(b);
  if (!left && !right) return 0;
  if (!left) return -1;
  if (!right) return 1;

  for (const key of ["major", "minor", "patch"]) {
    if (left[key] !== right[key]) {
      return left[key] > right[key] ? 1 : -1;
    }
  }

  if (left.pre === right.pre) return 0;
  if (!left.pre) return 1;
  if (!right.pre) return -1;
  return left.pre.localeCompare(right.pre, "en", { numeric: true });
}

async function fetchStaticRelease() {
  try {
    const response = await fetch(`./assets/data/release.json?t=${Date.now()}`, {
      cache: "no-store",
    });
    if (!response.ok) {
      return null;
    }
    return await response.json();
  } catch {
    return null;
  }
}

async function loadLatestRelease() {
  // 静态 release.json 由 dytes 发布后的同步 workflow 更新；version.js 由
  // dytes release workflow 直接上传到 packages 域名。两者取较高版本，避免
  // CDN 缓存或同步 workflow 尚未运行时页面回退到旧版本。
  const staticRelease = await fetchStaticRelease();
  const runtimeRelease = window.DYTES_RELEASE;
  const candidates = [staticRelease, runtimeRelease].filter(
    (release) => release && release.version,
  );

  if (candidates.length === 0) {
    return;
  }

  const newest = candidates.reduce((best, current) =>
    compareVersions(current.version, best.version) > 0 ? current : best,
  );
  const version = `v${String(newest.version).replace(/^v/, "")}`;
  const downloads = Object.assign(
    {},
    runtimeRelease && runtimeRelease.downloads,
    staticRelease && staticRelease.downloads,
  );

  document.querySelectorAll("[data-release-version]").forEach((node) => {
    node.textContent = version;
  });

  document.querySelectorAll("[data-release-link]").forEach((node) => {
    node.href = `https://github.com/dytescn/dytes/releases/tag/${version}`;
  });

  document.querySelectorAll("[data-download]").forEach((node) => {
    const url = downloads[node.dataset.download];
    if (url) {
      node.href = url;
    }
  });
}

loadLatestRelease();
