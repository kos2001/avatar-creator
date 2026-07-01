---
name: add-skill
description: Use when adding a new skill to an existing avatar (a per-individual Claude Code subagent). Creates ~/.claude/skills/<avatar>-<skill>/SKILL.md following skill-creator conventions and updates the avatar's "보유 skill" manifest in ~/.claude/agents/<avatar>.md. Triggers on "아바타에 skill 추가", "add skill to avatar", "give <avatar> the ability to ...".
---

# Add Skill — 아바타에 skill 추가

기존 아바타에 skill 하나를 추가한다. **두 가지 모드**를 지원한다:

- **부착(attach) — 우선.** 그 개인 PC에 **이미 설치된 skill/agent 중에서 골라** 아바타에
  연결한다. 새 파일을 만들지 않고 매니페스트에 참조만 기록한다. (사용자 방침: 아바타 skill은
  현재 사용 중인 skill 중 선택해 포함)
- **저작(author).** 마땅한 기존 skill이 없을 때만 전용 SKILL.md를 새로 만든다.
  산출물: `~/.claude/skills/<avatar>-<skill>/SKILL.md`.

두 모드 모두 아바타 매니페스트(`보유 skill` 섹션)를 갱신한다.
이 skill은 **자체 포함**이다. 아래 "skill 저작 규약"에 skill-creator 베스트프랙티스를
흡수해 두었으므로 다른 skill에 의존하지 않는다.

## 사전 조건
아바타가 존재해야 한다. `~/.claude/agents/<avatar>.md`가 없으면 먼저 `define-role`을
쓰라고 안내한다. 사용자가 어떤 아바타인지 안 밝히면 `~/.claude/agents/` 목록을 보여주고
고르게 한다.

## 절차

### 1. 대상 아바타 확인
- slug 확인. 해당 agent 파일을 읽어 역할·기존 보유 skill을 파악한다.

### 2. 필요 역량 파악 (한국어)
아바타에 더할 **역량 한 가지**가 무엇인지 한 문장으로 확인한다. (예: "기술 문서 작성",
"솔루션 설계 리뷰") 이미 맥락에서 충분하면 조기 종료.

### 3. 기존 설치 skill에서 선택 (부착 모드 — 우선)
그 개인 PC에 설치된 skill/agent 목록을 조회해, 역량에 맞는 후보를 제시한다:

```bash
~/.claude/skills/add-skill/scripts/list-skills.sh
```

- 출력은 `호출명<TAB>종류(skill|agent)<TAB>설명`. 역량 키워드로 후보를 골라 사용자에게 보인다.
- 사용자가 부착할 항목을 고르면(예: `@agent-technical-writer`, `/doc-coauthoring`),
  **step 6의 부착 모드**로 매니페스트에 기록한다. 새 파일은 만들지 않는다.
- 적합한 기존 skill이 없을 때만 step 4(저작)로 진행한다.

### 4. (저작 모드) skill slug 및 폴더
마땅한 기존 skill이 없을 때만 수행한다.
- skill slug: 소문자-kebab-case. 폴더명은 `<avatar>-<skill>` (아바타 소유 표시·충돌 방지).
- 경로: `~/.claude/skills/<avatar>-<skill>/SKILL.md` (없으면 디렉토리 생성).
- 이미 있으면 덮어쓸지 확인.

### 4b. (저작 모드) SKILL.md 작성
```markdown
---
name: <avatar>-<skill>
description: <무엇을 하는지 + 언제 쓰는지. 영어 트리거 문구. 구체적 상황·키워드 포함. "약간 push"하게 작성하여 undertrigger 방지>
---

# <skill 제목>

## 목적
<한 문장>

## 사용 시점
- <상황 1>
- <상황 2>

## 절차
1. <단계 — 명령형(imperative)으로>
2. <단계>

## 산출물
<무엇을 만들어내는지, 형식 포함>
```

### 6. 아바타 매니페스트 갱신
번들 스크립트로 결정적·멱등적으로 갱신한다. `(없음)` 제거·중복 방지·섹션 생성을 처리한다.

- **부착 모드** (기존 skill 선택):
  ```bash
  ~/.claude/skills/add-skill/scripts/update-manifest.sh --attach <avatar> <호출명> "<역량 한 줄>"
  # 예: ... --attach kim-fde @agent-technical-writer "기술 문서·제안 작성"
  ```
- **저작 모드** (새 skill 생성):
  ```bash
  ~/.claude/skills/add-skill/scripts/update-manifest.sh <avatar> <skill> "<목적 한 줄>"
  ```

### 7. 확인 및 안내
- 부착: 호출법(`@agent-<name>` 또는 `/<name>`)과 어떤 역량을 담당하는지 알린다.
- 저작: 생성 경로와 호출법(`/<avatar>-<skill>`)을 알린다.
- 매니페스트가 갱신돼 아바타가 이 skill을 인지함을 확인한다.

## skill 저작 규약 (자체 포함)
skill-creator 베스트프랙티스. 위 형식은 이를 따른다.

- **description이 1차 트리거 메커니즘**: "무엇을 하는지 + 언제 쓰는지"를 모두 담는다.
  모든 "when to use" 정보는 본문이 아니라 description에 둔다. Claude는 skill을
  **undertrigger**하는 경향이 있으니 description을 약간 "pushy"하게 쓴다
  (예: "…whenever the user mentions X, Y, or Z, even if they don't explicitly ask").
- **progressive disclosure**: SKILL.md는 500줄 이하. 길어지면 `references/`로 계층 분리하고
  본문에서 언제 읽을지 가리킨다. 결정적/반복 작업은 `scripts/`로 뺀다.
- **명령형(imperative)** 어조로 지시를 쓴다.
- **Single Responsibility**: 하나의 skill = 하나의 명확한 목적.
- **안전(Lack of Surprise)**: 악성코드·기만적 목적의 skill을 만들지 않는다.
  설명한 의도와 실제 동작이 일치해야 한다.

## 규약
- 전역 이름 충돌을 피하려 항상 `<avatar>-` 접두어를 붙인다.
- Implementation Completeness: TODO·미완성 절차를 남기지 않는다. 바로 쓸 수 있게 완성한다.
