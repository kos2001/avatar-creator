# Avatar Creator

각 개인을 위한 맞춤 agent를 **아바타**라 할 때, 아바타의 **역할**과 **skill**을
생성해주는 Claude Code 메타-skill 세트.

## 아바타란
- `~/.claude/agents/<avatar>.md` — subagent 정의 (역할·페르소나·보유 skill 목록)
- `~/.claude/skills/<avatar>-<skill>/SKILL.md` — 그 아바타 전용 skill들

## 메타-skill 3종
| skill | 용도 |
|---|---|
| `create-avatar` | 아바타를 처음부터 끝까지 생성 (오케스트레이터) |
| `define-role` | 아바타의 역할(subagent) 정의 |
| `add-skill` | 기존 아바타에 전용 skill 추가 |

## 설치
```bash
scripts/install.sh            # ~/.claude/skills/ 로 3개 skill 설치·갱신
scripts/install.sh --dry-run  # 무엇이 설치될지만 표시
```
(스크립트 없이도 `cp -R skills/* ~/.claude/skills/` 로 가능. 폴더째 복사되므로 번들 스크립트도 함께 설치됨.)

## 스크립트
| 스크립트 | 용도 |
|---|---|
| `scripts/install.sh` | 메타-skill을 `~/.claude/skills/`에 설치/갱신 (개발용) |
| `skills/add-skill/scripts/update-manifest.sh` | 아바타 `보유 skill` 매니페스트를 멱등적으로 갱신 (add-skill이 런타임에 호출) |

## 사용
- 전체 생성: `/create-avatar`
- 역할만: `/define-role`
- 기능 추가: `/add-skill`

설계 상세: [docs/superpowers/specs/2026-07-01-avatar-creator-design.md](docs/superpowers/specs/2026-07-01-avatar-creator-design.md)
