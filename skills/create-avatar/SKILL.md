---
name: create-avatar
description: Use when creating a complete personalized agent ("avatar") for a specific individual from scratch — orchestrates role definition plus a set of dedicated skills. Interviews about the person, delegates to define-role for the subagent, then to add-skill for each capability. Triggers on "아바타 만들기", "create an avatar", "make an agent for <person>", "<사람>을 위한 에이전트 만들어줘".
---

# Create Avatar — 아바타 전체 생성 (오케스트레이터)

한 개인을 위한 맞춤 agent(**아바타**)를 처음부터 끝까지 만든다.
= subagent 역할 정의 + 그 아바타 전용 skill 세트.

이 skill은 **오케스트레이터**다. 직접 파일을 쓰기보다 `define-role`과 `add-skill`의
절차를 순서대로 수행/위임한다.

## 절차

### 1. 대상 파악
"누구를 위한 아바타인가요? 그 사람의 역할을 한 줄로 알려주세요." — 대상을 확인한다.

### 2. 역할 정의 (define-role 위임)
`define-role` skill의 절차를 실행하여 페르소나 인터뷰를 진행하고
`~/.claude/agents/<avatar>.md` subagent 정의를 생성한다.
→ 여기서 아바타 slug가 확정된다.

### 3. 필요한 역량 도출 + 기존 skill 매핑 (우선)
정의된 역할·책임을 바탕으로 이 아바타에 필요한 **역량**을 정리한다.
그 개인 PC에 설치된 skill/agent 중에서 각 역량에 맞는 것을 먼저 찾아 매핑한다:

```bash
~/.claude/skills/add-skill/scripts/list-skills.sh
```

- 각 책임/역량 → 기존 설치 skill·agent 후보로 매핑해 목록으로 보여준다.
- 사용자에게 무엇을 **부착**할지 확인받는다. YAGNI — 과잉 생성 금지.
- 마땅한 기존 skill이 없는 역량만 새로 **저작** 대상으로 남긴다.

### 4. skill 부착/생성 (add-skill 반복 위임)
확인된 각 역량에 대해 `add-skill` 절차를 수행한다.
- **부착 모드(우선)**: 기존 skill/agent를 매니페스트에 참조로 기록.
- **저작 모드**: 기존에 없을 때만 `~/.claude/skills/<avatar>-<skill>/SKILL.md` 생성.
- 두 경우 모두 아바타 매니페스트("보유 skill" 섹션)를 갱신.

### 5. 요약 및 호출법 안내
완성 후 아래를 정리해 보여준다.
- 생성된 아바타 slug와 subagent 경로.
- 만들어진 skill 목록과 각 호출법 `/<avatar>-<skill>`.
- 아바타 직접 호출: `@agent-<avatar>`.
- 확장 안내: "나중에 기능을 더하려면 `add-skill`을 이 아바타에 사용하세요."

## 규약
- 전 과정 인터뷰 질문은 한국어, 한 번에 하나씩.
- 이미 받은 정보는 다시 묻지 않는다.
- define-role / add-skill의 규약(slug 형식, `<avatar>-` 접두어, 매니페스트 단일 소스)을 그대로 따른다.
- 실제 인물의 민감정보는 저장하지 않는다.
