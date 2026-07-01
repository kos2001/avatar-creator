# Avatar Creator — 설계 문서

작성일: 2026-07-01

## 목표

각 개인을 위한 맞춤 agent를 **아바타**라고 정의할 때, 아바타의 **역할(role)**과
**skill들**을 생성해주는 Claude Code 메타-skill 세트를 만든다.

## 핵심 개념

- **아바타 = 한 개인을 위한 맞춤 agent**
  - `~/.claude/agents/<avatar>.md` — subagent 정의 (역할·페르소나·보유 skill 목록)
  - `~/.claude/skills/<avatar>-<skill>/SKILL.md` — 그 아바타 전용 skill들
- 이 산출물을 만들어주는 **메타-skill 3개**를 `avatar-creator` 프로젝트에서 개발하고,
  완성 후 `~/.claude/skills/`에 설치하여 어디서든 호출 가능하게 한다.

## 3개 메타-skill

| skill | 역할 | 산출물 |
|---|---|---|
| `create-avatar` | 오케스트레이터. 인터뷰로 대상 파악 → `define-role` 위임 → 필요한 skill 목록화 → 각각 `add-skill` 위임 → 요약·호출법 안내 | 아바타 전체 |
| `define-role` | 대화형 인터뷰(이름·직무·전문성·책임·커뮤니케이션 스타일·도구)로 subagent 정의 생성 | `~/.claude/agents/<avatar>.md` |
| `add-skill` | 기존 아바타에 skill 하나 추가. skill-creator 규약(SKILL.md + frontmatter) 준수. 아바타 매니페스트의 skill 목록 갱신 | `~/.claude/skills/<avatar>-<skill>/SKILL.md` |

각 메타-skill은 **독립 호출 가능**하다. `define-role` 단독으로 역할만, `add-skill` 단독으로
기존 아바타에 기능만 추가할 수 있다.

## 데이터 흐름

```
사용자: create-avatar 실행
  → create-avatar: "누구를 위한 아바타?" 인터뷰
  → define-role: 페르소나 인터뷰 → ~/.claude/agents/<avatar>.md 작성
  → create-avatar: "이 역할에 필요한 skill은?" 제안·확인
  → add-skill × N: 각 skill의 SKILL.md 생성 + 매니페스트 갱신
  → 요약 + 호출법 안내 (@agent-<avatar>, /<avatar>-<skill>)
```

## 규약

- **언어**: skill frontmatter의 `name`/`description`과 트리거 문구는 영어(트리거 신뢰성),
  인터뷰 질문·생성되는 페르소나/역할 본문은 한국어.
- **아바타 slug**: 소문자-kebab-case. 예) `kim-marketing`.
- **skill 폴더명**: `<avatar>-<skill>` (전역 skill 이름 충돌 방지, 소유 아바타 식별).
- **매니페스트**: 별도 파일을 늘리지 않고 `~/.claude/agents/<avatar>.md` 본문의
  "보유 skill" 섹션을 단일 소스로 사용. `add-skill`이 이 섹션을 갱신한다.

## 산출물 형식

### subagent (`~/.claude/agents/<avatar>.md`)
frontmatter(`name`, `description`, 선택적 `tools`) + 본문(정체성 / 책임 / 행동 지침·커뮤니케이션 스타일 / 보유 skill).

### avatar skill (`~/.claude/skills/<avatar>-<skill>/SKILL.md`)
frontmatter(`name`, `description`) + 본문(목적 / 사용 시점 / 절차 / 산출물).

## 참조 연결 결정 (2026-07-02)

기존 유사 skill(`skill-creator`, `agent-development`)과 겹치는 부분은 **자체 포함(방식 B)**
으로 처리한다. 즉 런타임 위임(외부 skill 호출)이나 번들 복사 대신, 그 핵심 규약을
`define-role`·`add-skill` 본문에 흡수했다. 아바타 skill은 다른 skill 설치 여부와 무관하게
독립 동작하며, 설치는 3개 폴더 복사로 완결된다. 원본 규약 업데이트는 수동 반영한다.

## 비목표 (YAGNI)

- 아바타 실행 런타임, 웹 UI, 배포 파이프라인은 만들지 않는다.
- 별도 데이터베이스/레지스트리 서버 없음. 파일 기반.
