---
name: define-role
description: Use when creating or updating an avatar's role — a personalized Claude Code subagent for a specific individual. Conducts a Korean-language interview (name, job, expertise, responsibilities, communication style, tools) and writes a subagent definition to ~/.claude/agents/<avatar>.md. Triggers on "아바타 역할 만들기", "define role", "create a persona/subagent for <person>".
---

# Define Role — 아바타 역할(subagent) 생성

한 개인을 위한 맞춤 agent(**아바타**)의 역할을 정의하는 subagent 파일을 만든다.
산출물: `~/.claude/agents/<avatar>.md`.

이 skill은 **자체 포함**이다. 아래 "subagent 저작 규약"에 Claude Code subagent 작성
베스트프랙티스를 흡수해 두었으므로 다른 skill에 의존하지 않는다.

## 절차

### 1. 대화형 인터뷰 (한국어, 한 번에 하나씩)
아래 항목을 **질문 하나씩** 물어 페르소나를 구성한다. 이미 사용자가 준 정보는 다시 묻지 않는다.

1. **주인/이름** — 이 아바타는 누구를 위한 것인가? (사람 이름 또는 별칭)
2. **직무/역할** — 그 사람의 직무·직책은?
3. **전문 분야** — 어떤 도메인·기술에 강한가?
4. **핵심 책임** — 이 아바타가 대신 처리할 주요 업무 3~5개
5. **커뮤니케이션 스타일** — 말투/톤 (예: 간결·데이터 중심 / 친근·설명형 / 격식)
6. **도구 범위** — 특정 도구만 허용할지, 전체 도구를 쓸지 (최소 권한 원칙)

정보가 충분하면 조기에 인터뷰를 끝낸다. YAGNI — 불필요한 질문 금지.

### 2. slug 결정
주인 이름과 역할로 slug 생성. 예) 마케팅 팀장 김철수 → `kim-marketing`.
`~/.claude/agents/<slug>.md`가 이미 있으면 사용자에게 덮어쓸지/다른 slug를 쓸지 확인한다.

### 3. subagent 파일 작성
`~/.claude/agents/<slug>.md`를 아래 형식으로 작성한다. (디렉토리 없으면 생성)

```markdown
---
name: <slug>
description: Use this agent when <이 아바타를 호출할 조건(영어)>. Typical triggers include <상황1>, <상황2>, <상황3>. <이름>의 아바타 — <직무 한 줄 요약>.
model: inherit
color: <blue|cyan|green|yellow|magenta|red 중 하나>
tools: <제한 시 배열 예 ["Read","Write","Grep"], 전체면 이 줄 생략>
---

당신은 <이름>의 아바타로, <직무·전문 분야>를 담당하는 에이전트입니다.

## When to invoke (호출 시점)
- **<상황 이름>.** <어떤 상황에서 무엇을 하는지>
- **<상황 이름>.** <...>

## 핵심 책임
1. <책임 1>
2. <책임 2>
3. <...>

## 행동 지침 / 커뮤니케이션 스타일
- <스타일 규칙 (인터뷰의 톤 반영)>
- 근거 기반으로 답하고, 불확실하면 불확실하다고 말한다.

## 보유 skill
<!-- add-skill 이 이 목록을 갱신한다. 아직 없으면 "(없음)" -->
- (없음)
```

### 4. 확인 및 안내
- 작성한 파일 경로를 알린다.
- 호출법 안내: `@agent-<slug>` 로 이 아바타를 직접 호출.
- 다음 단계 제안: "이 역할에 skill을 추가하려면 `add-skill`을 사용하세요."

## subagent 저작 규약 (자체 포함)
Claude Code subagent 작성 베스트프랙티스. 위 형식은 이를 따른다.

- **name** (필수): 소문자·숫자·하이픈만, 3~50자, 영숫자로 시작·끝. slug와 일치.
- **description** (필수, 가장 중요): 컨텍스트에 항상 로드되어 하네스가 호출 시점을 판단한다.
  - "Use this agent when …" 형태로 트리거 조건 명시.
  - 대표 트리거 상황 2~4개를 산문으로 요약(능동/수동 호출, 다양한 표현 포함).
  - 본문 "When to invoke"에 상세 시나리오를 둔다.
- **model**: `inherit` 권장(특별한 이유 없으면).
- **color**: blue/cyan/green/yellow/magenta/red 중 하나(아바타별로 구분).
- **tools** (선택): 최소 권한. 생략 시 전체 도구. 읽기전용=["Read","Grep","Glob"] 등.
- **본문 = 시스템 프롬프트**: 2인칭("당신은 …")으로 에이전트에게 직접 지시. 책임·워크플로·출력형식 순.

## 규약
- frontmatter는 영어 트리거 신뢰성 확보, 본문(페르소나·지침)은 한국어 허용.
- 실제 인물의 민감정보(연락처·주소 등)는 저장하지 않는다. 역할·업무 맥락만 기록한다.
