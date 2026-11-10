# Aigoo

讓 Windows 電腦一行指令裝好 Claude Code 工作環境（One line sets up a Claude Code workspace on Windows）。

## 安裝（Install）

在 PowerShell 裡貼上並執行（Paste into PowerShell and run）：

```powershell
irm https://raw.githubusercontent.com/billwuatenlab/Aigoo/main/install.ps1 | iex
```

安裝程式會（The installer will）：

1. 缺什麼裝什麼：Git、Python 3.13、Node.js LTS、Bun、uv、GitHub CLI `gh`（選用）、RustDesk。先用 winget，失敗再從官方網站下載並核對 SHA256 或簽章（installs missing tools; winget first, official downloads with SHA256/signature checks as fallback）。
2. 安裝 Claude Code、Orca 和 claude-mem plugin（installs Claude Code, Orca and the claude-mem plugin）。
3. 放入 `CLAUDE.md`、`settings.json` 和 hooks（五階段工作流程 `stage_gate.py`、每日簡報）（installs CLAUDE.md, settings and hooks）。
4. 在桌面建立 `Claude Code` 捷徑（creates a Desktop shortcut）。
5. 印出檢查清單，安裝紀錄存在桌面 `Aigoo_V<版本>_<時間>.log`（prints a checklist; the log is on the Desktop）。

裝完之後（Afterwards）：開一個新的終端機，執行 `claude` 並輸入 `/login`（open a new terminal, run `claude`, then `/login`）。

## 自動更新（Auto-update）

開啟 Claude Code 時，一天最多檢查一次這個 repo 的新版本；有新版就開一個看得見的視窗，用補丁模式安裝，不需要登入 GitHub（Claude Code checks this repo at most once a day and installs a newer version in Patch mode; no GitHub sign-in needed）。

## 不包含（Not included）

Aigoo 不帶任何記憶、claude-mem 資料庫或個人資料；claude-mem 會在第一次啟動 Claude 時建立空的資料庫（Aigoo ships no memory, no claude-mem database and no personal data）。

## 注意：會移除內部版 AIGO（Note: removes the internal AIGO edition）

如果這台電腦裝過內部版 AIGO，Aigoo 安裝時會**不詢問、不備份**，直接刪除 AIGO 的專案記憶、claude-mem 資料庫、AIGO 更新 hook 和舊的 `.bak-*` 備份；已安裝的程式會保留（If the internal AIGO edition is found, its memory, claude-mem database, update hook and old backups are deleted without a prompt or backup; installed programs are kept）。

## 問題回報（Issues）

請到 https://github.com/billwuatenlab/Aigoo/issues ，並附上桌面的安裝紀錄（attach the Desktop log）。
