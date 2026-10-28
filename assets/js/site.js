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

async function loadLatestRelease() {
  try {
    const response = await fetch(
      "https://api.github.com/repos/dytescn/dytes/releases/latest",
      { headers: { Accept: "application/vnd.github+json" } },
    );

    if (!response.ok) {
      return;
    }

    const release = await response.json();
    const version = release.tag_name || "latest";

    document.querySelectorAll("[data-release-version]").forEach((node) => {
      node.textContent = version;
    });

    document.querySelectorAll("[data-release-link]").forEach((node) => {
      if (release.html_url) {
        node.href = release.html_url;
      }
    });
  } catch {
    // 网络不可用时保留页面上的 latest 文本。
  }
}

loadLatestRelease();
