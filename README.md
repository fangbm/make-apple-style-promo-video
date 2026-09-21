# Make Apple-Style Promo Video

[English](README.en.md) | [Skill instructions](SKILL.md) | [Template](assets/promo-template/promo.html)

为 Codex 准备的产品宣传片 Skill：用确定性的 HTML、CSS 与 JavaScript 场景逐帧渲染，编码为可发布的 MP4，并对真实成片做视觉与技术验收。

它适合软件发布片、浏览器扩展演示、功能短片和产品预告。目标不是交付一张分镜或一个网页预览，而是一支完成编码、带声音、可直接上传的平台成片。

## 成片示例

[![TermPop：不离开页面，也能看懂术语](https://i0.hdslb.com/bfs/archive/81f6ec8caf809ba3d0d803f14ef08fc765af9324.jpg)](https://www.bilibili.com/video/BV1oB3x6aE5e)

**TermPop：不离开页面，也能看懂术语**  
点击封面在 [B 站观看](https://www.bilibili.com/video/BV1oB3x6aE5e)。

## 交付什么

- 固定画布、逐帧可复现的产品演示场景；
- 基于真实 UI 几何定位的鼠标、菜单、弹层和箭头；
- 16:9 H.264/AAC MP4，带 `faststart`、正确帧率与时长；
- 编码后从最终 MP4 提取的关键帧、SSIM 对比与技术探测；
- 音乐来源、许可和署名记录，避免把临时配乐误当作可发布素材。

## 安装

将仓库放入 Codex Skill 目录：

```powershell
git clone https://github.com/fangbm/make-apple-style-promo-video.git `
  "$env:USERPROFILE\.codex\skills\make-apple-style-promo-video"
```

然后直接对 Codex 说：

```text
使用 $make-apple-style-promo-video 为这个产品制作一支可直接发布的 16:9 果味宣传片。
```

## 快速开始

需要 Node.js、FFmpeg、PowerShell，以及可供 Playwright 调用的 Chromium 或 Edge。

```powershell
$skill = "$env:USERPROFILE\.codex\skills\make-apple-style-promo-video"
& "$skill\scripts\new_promo_project.ps1" `
  -OutputDirectory "D:\work\promo" `
  -ProductName "YourProduct"

node "$skill\scripts\capture_stills.mjs" `
  --source "D:\work\promo\promo.html" `
  --output "D:\work\promo\artifacts\stills"

& "$skill\scripts\render_video.ps1" `
  -Source "D:\work\promo\promo.html" `
  -Output "D:\work\promo\artifacts\promo.mp4"

& "$skill\scripts\validate_video.ps1" `
  -Video "D:\work\promo\artifacts\promo.mp4" `
  -ExpectedDuration 31.2
```

没有获授权音乐时，成片只能作为 review cut。使用 `-Publishable` 时必须同时提供音乐文件、来源链接、许可与署名信息。

## 工作方式

1. 先确认产品、受众、真实功能、语言、时长与素材许可。
2. 写精确到秒的分镜，先安排产品揭示、核心交互、第二场景、收尾。
3. 在 `window.renderAt(time)` 中由时间唯一决定每个视觉状态，杜绝网络、随机值和不可控动画时钟。
4. 用 DOM `getBoundingClientRect()` 锚定鼠标、右键菜单和解释卡；不要目测猜位置。
5. 在全量编码前捕获所有关键状态的静帧，逐张检查排版、鼠标方向、卡片箭头和文字可读性。
6. 对最终 MP4 做编码、时长、黑帧、关键帧和音视频同步验收。

完整规范在 [SKILL.md](SKILL.md)。

## 仓库结构

| 路径 | 用途 |
| --- | --- |
| [SKILL.md](SKILL.md) | 给 Codex 的完整执行规范与验收标准 |
| [assets/promo-template](assets/promo-template) | 六场景确定性 HTML 起始模板 |
| [scripts](scripts) | 建项目、渲染帧、抓静帧、编码和验收脚本 |
| [references/style-system.md](references/style-system.md) | 视觉、排版、动效和声音语言 |
| [references/storyboard-patterns.md](references/storyboard-patterns.md) | 分镜与文案节奏 |
| [references/qa-checklist.md](references/qa-checklist.md) | 成片验收清单与常见问题 |

## 原则

- 展示真实产品，而不是只做氛围图；
- 先审静帧，再编码整片；
- 卡片、鼠标和高亮必须锚定真实目标；
- 成片验收以最终 MP4 为准，不以 HTML 预览为准；
- 只有已确认授权的音乐才能作为公开发布版本的配乐。
