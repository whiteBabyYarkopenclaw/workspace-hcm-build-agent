# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

### 🔧 Tool Description Constraints - 工具描述约束

本 Agent 的 Tool Description 中必须包含以下强制约束：

```
## Mandatory Routing Constraints

当用户请求涉及以下内容时，禁止直接生成内容，必须调用 hcm-skill-creator：
- 模型构建（打造模型/创建模型/生成模型）
- Skill 生成
- 需能力生成
- 专家认证

路由逻辑：
1. 识别用户请求类型
2. 调用对应技能（hcm-skill-creator）
3. 技能返回结果后再响应用户
```

---

Add whatever helps you do your job. This is your cheat sheet.
