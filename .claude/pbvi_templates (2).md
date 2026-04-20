---
name: pbvi-templates
version: v3.7
description: >
  PBVI artifact templates — load this file when generating any PBVI artifact.
  Contains: Session Log, Verification Record, ENH-NNN_SCOPE.md, Enhancement Brief,
  Sprint Manifest, Sprint Log, ENH-NNN_SPRINT_CONSTRAINTS.md, PHASE4_GATE_RECORD.md.
  The ENH-NNN_BCE_IMPACT.md template is maintained exclusively in bce_core.md — not
  in this file. Load alongside pbvi_core.md or pbvi_sprint.md as needed.
---

# PBVI Templates — v3.7

## Changelog

| Version | Date | Summary |
|---|---|---|
| v3.7 | April 2026 | PBVI-006 — Template 8 added: PHASE4_GATE_RECORD.md — canonical template for the Design Gate record with four sections: evaluation criteria, requirements traceability, adversarial stress test findings, and risk register with RESOLVE/ACCEPT dispositions, overall verdict, and engineer sign-off block. |
| v3.6 | April 2026 | FW-001 — Version compatibility check added to Template 2B REPOSITORY CONTEXT section. After branch confirmation, the agent reads PROJECT_MANIFEST.md METHODOLOGY_VERSION, compares against the loaded skill frontmatter version, and outputs a named warning block if they differ — then continues without stopping the session. |
| v3.5 | April 2026 | CQ-001 — Template 2B challenge agent evaluation criteria made explicit: structural complexity check added as a named finding category — conditional nesting depth and single-purpose compliance per new or modified function against the core definition in Claude.md. Verdict: CLEAN or FINDINGS. Engineer dispositions per existing ACCEPT-with-rationale or TEST mechanism. |
| v3.4 | April 2026 | Template 2B made self-contained: TASK-LEVEL VERIFICATION (14 steps), GIT HYGIENE, FAILURE HANDLING, CHALLENGE FINDINGS HANDLING, SCOPE VIOLATION HANDLING, HUMAN GATES, SCOPE AND INVARIANT RULES, and closing paragraph embedded inline. Stale skill cross-references in STOP CONDITIONS removed. EXECUTION MODE language aligned with unified prompt. Template 1 execution mode label updated from CC Challenge to Challenge Agent. |
| v3.3 | April 2026 | Wave 5 agentic build changes: Template 2B — Session Execution Prompt added. Ten sections: execution mode, agent identity, repository context, what has already been built, planning artifacts, scope boundary, task prompt immutability, session tasks, artifact paths, stop conditions and output formats (PBVI-T-001, PBVI-T-002). |
| v3.2 | April 2026 | Wave 4 agentic build changes: Verification Record Template 2 — CC Challenge Output section replaced with Challenge Agent Output section. Structure updated: verdict field, four evidence tables, finding dispositions table. Verification Verdict checklist updated — CC challenge reviewed replaced with challenge agent verdict and findings disposition checkboxes; pre-commit declaration checkbox added (PBVI-M-009). |
| v2.9 | April 2026 | Initial release — templates extracted from PBVI skill to standalone file. Contains: Session Log, Verification Record, ENH-NNN_SCOPE.md, Enhancement Brief, Sprint Manifest, Sprint Log, ENH-NNN_SPRINT_CONSTRAINTS.md. ENH-NNN_BCE_IMPACT.md maintained exclusively in BCE skill. |
| v3.1 | April 2026 | Session Log: SIGNED OFF machine-readable marker added to Session Completion; Resumed Sessions table extended with Resolved at and Root cause fields (PLANNING GAP / ENVIRONMENTAL / SCOPE CREEP); Out of Scope Observations section added between Deviations and Claude.md Changes. ENH-NNN_SCOPE.md: Phase 3 Gate — Tier Reconfirmation section added as Section 7; Engineer Sign-Off renumbered to Section 8. |
| v3.0 | April 2026 | Invariant scope split — Template 2 Code Review references TASK-SCOPED invariants from task prompt and GLOBAL from Claude.md. Template 3 Section 4 adds GLOBAL/TASK-SCOPED classification table. Section 5 clarifies TASK-SCOPED additions do not trigger Claude.md version bump. Section 6 Tier 3 criteria updated to match. |

---

## How to Use This File

Load this file as a project file alongside the PBVI skill. When the skill instructs
"generate using the template from PBVI_TEMPLATES", use the corresponding template here.

**ENH-NNN_BCE_IMPACT.md is NOT in this file.** It is maintained exclusively in the
BCE skill. Load the BCE skill as a project file to access it.

**Template integrity rules apply to all templates here:**
- Fields marked LEAVE BLANK must never be pre-populated
- Fields marked pre-populate from EXECUTION_PLAN.md are populated at template creation
- Prediction statements are left blank in Manual mode; omitted entirely in Autonomous mode
- Human sign-off fields are never pre-filled

---

## Template 1 — Session Log (SESSION_LOG.md)

**When to generate:** At the start of every build session, before the first task begins.
**Pre-populate:** Task Id and Task Name from EXECUTION_PLAN.md. Leave Status and Commit blank.
**Leave blank:** All status fields, commit hashes, sign-off, decision log, deviations.

```markdown
# SESSION_LOG.md

## Session: [Session Name]
**Date started:** 
**Engineer:** 
**Branch:** session/s[n]_<short_desc>
**Claude.md version:** 
**Execution mode:** [ ] Manual (prediction discipline, prediction before verification)
                  | [ ] Autonomous (sequential, no interruption, no prediction)
**Status:** In Progress

## Tasks

| Task Id | Task Name | Status | Commit |
|---------|-----------|--------|--------|
| [n.n]   | [name]    |        |        |

Valid Status values: Completed | BLOCKED | SKIPPED
SKIPPED is set by the engineer manually outside of any execution prompt.
BLOCKED is set by CC on verification failure in Autonomous mode.

---

## Resumed Sessions (Autonomous mode only)

| Resumed at | Resumed from Task | Blocking issue resolution | Resolved at | Root cause |
|------------|-------------------|--------------------------|-------------|------------|
|            |                   |                           |             |            |

Leave this table empty if the session was not resumed.

Root cause values: PLANNING GAP | ENVIRONMENTAL | SCOPE CREEP
- PLANNING GAP: a planning assumption was wrong — loop may be required
- ENVIRONMENTAL: infrastructure or config issue — no loop required
- SCOPE CREEP: agent exceeded its scope boundary — review session output

The engineer fills Resolved at and Root cause at resolution time, not at
the point of the BLOCKED stop. These fields are never pre-filled by the agent.

---

## Decision Log

| Task | Decision made | Rationale |
|------|---------------|-----------|
|      |               |           |

---

## Deviations

| Task | Deviation observed | Action taken |
|------|--------------------|--------------|
|      |                    |              |

---

## Out of Scope Observations

[Items noticed during build that are outside this session's scope.
Each item is recorded here and deferred — not acted on by the agent.
Engineer reviews at session sign-off and determines disposition.]

| Task | Observation | Nature | Recommended action |
|------|-------------|--------|--------------------|
|      |             |        |                    |

Nature values: BUG | MISSING | FRAGILITY
Disposition at sign-off: BACKLOG | DISMISS | IMMEDIATE (requires loop)

Leave this table empty if no out-of-scope items were noticed.

---

## Claude.md Changes

| Change | Reason | New Claude.md version | Tasks re-verified |
|--------|--------|-----------------------|-------------------|
| None   |        |                       |                   |

---

## Session Completion
**Session integration check:** [ ] PASSED
**All tasks verified:** [ ] Yes
**Blocked tasks resolved:** [ ] Yes — N/A if no BLOCKED tasks occurred
**PR raised:** [ ] Yes — PR #: [branch] → main
**Status updated to:** 
**Engineer sign-off:** 
SIGNED OFF: [name] — [date]

Note: The SIGNED OFF line is machine-readable. It must appear exactly
as shown — no bold markers, no other formatting. The launcher serial
gate greps for `^SIGNED OFF:` and will fail if the line is wrapped in
markdown (`**SIGNED OFF:**`). Do not use any other phrasing for sign-off.
```

---

## Template 2 — Verification Record (VERIFICATION_RECORD.md)

**When to generate:** Per task, at the start of each task before running any commands.
**Pre-populate:** Task ID, Task Name, Scenario, Expected from EXECUTION_PLAN.md.
**Leave blank:** Result column, Prediction Statement (Manual) or omit entirely (Autonomous),
Challenge Agent Output, Code Review results, Scope Decisions, BCE Impact, all verdict
checkboxes, Finding dispositions table.

```markdown
**Session:** [Session Name]
**Date:** 
**Engineer:** 

## [Task n.n — Task Name]

### Test Cases Applied
Source: EXECUTION_PLAN.md Session [n]

| Case | Scenario | Expected | Result |
|------|----------|----------|--------|
| TC-1 | [from execution plan] | [from execution plan] | |
| TC-2 | [from execution plan] | [from execution plan] | |

### Prediction Statement
[LEAVE BLANK — engineer writes predictions before running verification commands]

### Challenge Agent Output
[Written by the build agent from ./tools/challenge.sh output.
Leave blank at template creation — populated during task execution.]

**Verdict:** CLEAN | FINDINGS

**Untested scenarios:**
[From challenge agent output — or write NONE if CLEAN verdict]

**Unverified assumptions:**
[From challenge agent output — or write NONE if CLEAN verdict]

**Invariant coverage gaps:**
[From challenge agent output — or write NONE if CLEAN verdict]

**Scope boundary observations:**
[From challenge agent output]

**Finding dispositions (FINDINGS verdict only):**

| Finding # | Disposition | Rationale / Test case added | Test result |
|-----------|-------------|------------------------------|-------------|
|           |             |                              |             |

Leave Finding dispositions table empty if verdict is CLEAN.

### Code Review
[Required only if this task touches an invariant. For TASK-SCOPED invariants,
the invariant text is already embedded in the task's CC prompt in EXECUTION_PLAN.md
— reference it here. For GLOBAL invariants, source from Claude.md Section 2.
List specific code review items: what to look for and where. Leave results blank.]

### Scope Decisions
[What was accepted as out of scope and why. Cannot be left blank for deliverables.]

### BCE Impact
[Required when this task touches a module with a MODULE_CONTRACTS.md entry.
If no BCE artifact is affected, write: No BCE artifact impact.]

| Artifact | Field | Change |
|---|---|---|

### Verification Verdict
[ ] All planned cases passed
[ ] Challenge agent run — verdict recorded (CLEAN or FINDINGS)
[ ] All FINDINGS dispositioned — ACCEPT with rationale or TEST with result
[ ] Pre-commit declaration recorded
[ ] Code review complete (if invariant-touching)
[ ] Scope decisions documented

**Status:**
```

---

## Template 2B — Session Execution Prompt

**When to generate:** At the end of Phase 5, after Claude.md is committed.
One file per session in EXECUTION_PLAN.md.
**Path (greenfield):** `sessions/S[N]_execution_prompt.md`
**Path (enhancement):** `sessions/SPRINT-NNN/ENH-NNN/S[N]_execution_prompt.md`
**Leave blank:** Nothing — this is a complete reference document when generated.
**Gate:** All files committed before Phase 6 begins.
```markdown
# S[N] Execution Prompt — [Project / ENH-NNN] — [Session Title]

**Session:** S[N]
**Project / Enhancement:** [project slug or ENH-NNN]
**Branch:** session/s[N]_[short_desc]
**Produced:** Phase 5 — [date]

---

## EXECUTION MODE

[Autonomous | Manual] — declare the mode for this session.

Autonomous: Execute all tasks sequentially without pausing between tasks unless
a human gate is explicitly marked in EXECUTION_PLAN.md. Do not pause for
prediction statements — this mode does not use them.

Manual: Pause after each task for the engineer's prediction statement, challenge
finding dispositions, and commit confirmation before proceeding to the next task.

---

## AGENT IDENTITY

You are the build agent for [project / ENH-NNN], Session S[N].
You have no memory of prior sessions. All context you need is in this file
and the planning artifacts listed below.
Do not infer context from session logs or other files not listed here.

---

## REPOSITORY CONTEXT

Repo root: [absolute path]
Session branch: session/s[N]_[short_desc]

Before any task work: confirm this branch exists and you are on it.
If it does not exist: stop immediately. Output:

  LAUNCH ERROR
  ------------
  Branch session/s[N]_[short_desc] not found.
  Create branch before launching this session.

Then read PROJECT_MANIFEST.md and locate the METHODOLOGY_VERSION field.
Compare it against the version in the loaded PBVI skill's frontmatter.
If they match: proceed silently.
If they differ or the field is absent: output the following, then continue —
do not stop the session.

  METHODOLOGY VERSION WARNING
  ---------------------------
  Skill version:    [from skill frontmatter]
  Project version:  [from METHODOLOGY_VERSION field, or NOT DECLARED]

  This project was initialised under a different methodology version.
  Proceeding may produce incomplete or unexpected results.
  Consult BREAKING_CHANGES.md in the DG-Forge repo before continuing.

---

## WHAT HAS ALREADY BEEN BUILT

[S01: write exactly — "This is the first session. Repository scaffolded.
No prior session state."]

[S02 onward: one paragraph — what the prior session delivered, what
invariants were verified, what state the system is in at the start of
this session. Written during Phase 5 while the plan is fresh.]

---

## PLANNING ARTIFACTS — READ BEFORE TASK 1

Read these files in order before beginning Task 1:

1. docs/Claude.md — your execution contract. Governs everything.
2. [docs/EXECUTION_PLAN.md | enhancements/SPRINT-NNN/ENH-NNN/ENH-NNN_EXECUTION_PLAN.md]
3. [enhancements/SPRINT-NNN/ENH-NNN/ENH-NNN_SPRINT_CONSTRAINTS.md]
   (Enhancement only — omit for greenfield.)

If any listed file is missing: stop immediately. Output:

  LAUNCH ERROR
  ------------
  [filename] not found.
  Cannot begin session without complete planning artifacts.

---

## SCOPE BOUNDARY

You may only create or modify these files:
[list exact files — scoped to this session's tasks, not the full project scope]

---

## TASK PROMPT IMMUTABILITY

The task prompt in EXECUTION_PLAN.md is a contract, not a starting point.
Execute it exactly as written. The following are not permitted:
- Extending the task beyond its stated scope
- Adding functionality not specified in the task prompt
- Fixing adjacent issues encountered during execution
- Improving code outside the task boundary

If something outside scope is noticed: record it in Out of Scope
Observations in SESSION_LOG.md. Do not act on it.

---

## SESSION TASKS

Execute tasks [T-NN] through [T-NN] from [EXECUTION_PLAN.md path].
Use the exact task prompt as written. Do not paraphrase. Do not combine.
Do not skip.

---

## ARTIFACT PATHS FOR THIS SESSION

SESSION_LOG:          [sessions/S[N]_SESSION_LOG.md |
                       sessions/SPRINT-NNN/ENH-NNN/S[N]_SESSION_LOG.md]
VERIFICATION_RECORD:  [sessions/S[N]_VERIFICATION_RECORD.md |
                       sessions/SPRINT-NNN/ENH-NNN/S[N]_VERIFICATION_RECORD.md]

Create both at session start per template integrity rules. Do not pre-fill result fields.

---

## GIT HYGIENE

After each task completes and its verification passes:
1. Stage only the files modified by that task
2. Commit — see step 12 in TASK-LEVEL VERIFICATION for the required format
3. Do not batch multiple tasks into a single commit

Command execution — critical: Do NOT chain commands using &&. Run each
command as a separate, sequential step.

---

## TASK-LEVEL VERIFICATION (strict order — applies to both modes)

For each task:
1. Create/update the Verification Record. Pre-populate Task ID, Task Name,
   Scenario, and Expected from EXECUTION_PLAN.md.
   Manual: include the Prediction Statement section — leave blank at creation.
   Autonomous: omit the Prediction Statement section entirely — do not leave
   it blank, remove it from the record.
   Leave Result, Challenge Agent Output, BCE Impact, and Verdict checkboxes blank.
2. Run the task CC prompt from EXECUTION_PLAN.md exactly as written.
3. Manual only — STOP. Present the task output summary and wait for the engineer
   to write their prediction statement before proceeding to step 4.
   Autonomous: proceed directly to step 4.
4. Run the verification command and evaluate all test cases. Record results.
5. If verification fails: invoke FAILURE HANDLING immediately. Do not proceed
   to steps 6–14.
6. FILE BOUNDARY CHECK — run: git diff --name-only HEAD
   Compare every file against the SCOPE BOUNDARY list above.
   If any file is not on the permitted list: invoke SCOPE VIOLATION handling.
   Do not proceed to step 7.
7. PRE-COMMIT DECLARATION — output the following block and write it to the
   Verification Record before any commit:

   PRE-COMMIT DECLARATION — [Task ID]
   -----------------------------------
   Files modified:     [git diff --name-only HEAD output]
   Functions added:    [list or NONE]
   Functions modified: [list or NONE]
   Functions deleted:  [list or NONE]
   Schema changes:     [list or NONE]
   Config changes:     [list or NONE]

   Everything above is within the task prompt scope: YES / NO

   If NO on any item: invoke SCOPE VIOLATION handling. Do not proceed to step 8.

8. CHALLENGE AGENT — run: ./tools/challenge.sh S[N] [TASK_ID]
   The challenge agent receives: docs/Claude.md, this task's section from
   EXECUTION_PLAN.md, git diff for this task, this task's Verification Record
   entries, docs/INVARIANTS.md. No build session context.
   The challenge agent evaluates: untested scenarios, unverified assumptions,
   invariant coverage gaps, scope boundary observations, and structural complexity
   — conditional nesting depth and single-purpose compliance per new or modified
   function against the core definition in Claude.md. Structural complexity verdict:
   CLEAN or FINDINGS. Engineer dispositions structural complexity findings per the
   existing ACCEPT-with-rationale or TEST mechanism.
   Write full output to the Challenge Agent Output section of Verification Record.
   CLEAN → proceed to step 9.
   FINDINGS → invoke CHALLENGE FINDINGS handling. Do not proceed to step 9.
9. BCE Impact: check discovery/ for MODULE_CONTRACTS.md entries for any module
   touched by this task. Record impact or write "No BCE artifact impact."
10. Out of Scope Observations: record anything noticed outside task scope in the
    Out of Scope Observations table in SESSION_LOG. Do not act on it.
11. Record PASS verdict — confirm all checkboxes.
12. Commit:
    Manual:
    [SESSION_NUMBER].[TASK_NUMBER] — [Task Name]: [one-line summary]

    Autonomous:
    [S][N].[TASK_N] — [Task Name]: [one-line summary]

    Scope: within Claude.md boundary — YES
    Files: [list every file created or modified]
    Invariants touched: [INV-XX list — or NONE]
    Pre-commit declaration: recorded in VERIFICATION_RECORD

13. Update session log.
14. Manual: STOP. Confirm with the engineer before proceeding to the next task.
    Autonomous: Proceed immediately to the next task.

---

## FAILURE HANDLING

If any verification command produces a failing result:
1. Do not attempt to fix the failure.
2. Record BLOCKED in the session log (Status = BLOCKED, Commit = none).
3. Write full verification output verbatim into Verification Record Result field.
4. Write failure classification: ENVIRONMENTAL | SCOPE GAP | UNKNOWN
5. Stop the session. Do not proceed to the next task under any circumstances.
6. Output:

   SESSION BLOCKED
   ---------------
   Task ID:              [task id]
   Task Name:            [task name]
   Verification command: [exact command that failed]
   Failure output:       [full output verbatim]
   Classification:       [ENVIRONMENTAL | SCOPE GAP | UNKNOWN]
   Engineer action:      Resolve the blocking issue, then use the Resume prompt
                         to continue from this task.

---

## CHALLENGE FINDINGS HANDLING

If challenge agent returns a verdict of FINDINGS:
1. Do not commit.
2. Record CHALLENGE FINDINGS in session log (Status = CHALLENGE FINDINGS,
   Commit = none).
3. Output:

   CHALLENGE FINDINGS
   ------------------
   Session:  S[N] — [project/ENH-NNN]
   Task:     [Task ID] — [Task Name]
   Findings: [N]

   [paste full challenge agent output]

   Engineer action: for each finding, respond with one of:
     ACCEPT [N] — [rationale]
       Gap acknowledged. Rationale recorded in Verification Record.
       No test required. Session continues after all findings dispositioned.
     TEST [N] — [test case description]
       Add the specified test case, run it immediately, record the result.
       If PASS: continue dispositionning remaining findings.
       If FAIL: invoke FAILURE HANDLING. Session stops.

4. Manual: wait for engineer to disposition all findings in the conversation.
   Resume from step 9 after all findings are dispositioned.
   Autonomous: stop the session.
   Resume: ./tools/resume_challenge.sh [mode] [identifier] S[N] [Task ID]

---

## SCOPE VIOLATION HANDLING

If file boundary check (step 6) or pre-commit declaration (step 7) identifies
a scope violation:
1. Do not commit.
2. Record SCOPE VIOLATION in session log (Status = SCOPE VIOLATION, Commit = none).
3. Output:

   SCOPE VIOLATION
   ---------------
   Session:    S[N] — [project/ENH-NNN]
   Task:       [Task ID] — [Task Name]
   Violation:  FILE_BOUNDARY | TASK_OVERREACH | PRE_COMMIT_MISMATCH
   Detail:     [specific file, function, or behaviour outside scope]
   Evidence:   [git diff --name-only output or declaration mismatch]

   Violation types:
   - FILE_BOUNDARY: a file outside the permitted list was modified
   - TASK_OVERREACH: a function, schema change, or config change not
     required by the task prompt was made within permitted files
   - PRE_COMMIT_MISMATCH: declaration self-certification returned NO

   Engineer action:
     ACCEPT [violation] — [rationale]: scope boundary update required.
     REVERT: git checkout -- . then ./tools/resume_session.sh [args]

4. Stop the session. Do not proceed to the next task under any circumstances.

---

## HUMAN GATES

If EXECUTION_PLAN.md marks a task or decision point as [HUMAN GATE], stop and
wait for engineer input before proceeding. Human gates override autonomous mode.

---

## SCOPE AND INVARIANT RULES

- Invariant conflict: invariant wins. Flag it; never resolve silently.
- Gap not covered by task prompt or Claude.md: do the minimum and flag the gap.
- No design decisions not covered by Claude.md or EXECUTION_PLAN.md.

---

## SESSION COMPLETE

When all tasks complete with PASS verdicts, output exactly:

  SESSION COMPLETE
  ----------------
  Session:      S[N] — [project/ENH-NNN]
  Tasks:        [N] completed, 0 blocked, 0 scope violations, 0 findings
  Branch:       session/s[N]_[short_desc]
  Final commit: [hash]
  Artifacts:    [SESSION_LOG path], [VERIFICATION_RECORD path]
  Scope clean:  YES

  Engineer action: review artifacts and sign off SESSION_LOG.

---

Begin by reading all PLANNING ARTIFACTS in order and confirming session state.
Manual: present the task list for this session and wait for the engineer to
confirm before starting the first task.
Autonomous: execute all tasks in this session sequentially.
```

---

## Template 3 — ENH-NNN_SCOPE.md

**When to generate:** At scoping gate before build begins. Engineer declares Sign-Off Tier here.
**Leave blank:** Engineer Sign-Off section.

```markdown
# ENH-NNN_SCOPE.md — [Enhancement Name]
**Enhancement:** ENH-NNN
**Engineer:** [name]
**Type:** A | B
**Status:** IN SCOPING | SCOPED | IN EXECUTION | COMPLETE

## 1. Enhancement Summary
[One paragraph — what this enhancement does and why]

## 2. Scope
**In scope:**
[Explicit list of what will change]

**Out of scope:**
[Explicit list of what will not change — not "TBD", must be stated]

## 3. BCE Impact Assessment
[Planning declaration only — states expected impact for scoping purposes.
Do not update discovery/ artifacts here. In a sprint context, all discovery/
updates are deferred to sprint close-out via Sprint Lead BCE refresh.]
[List affected artifacts — or state "No BCE artifact impact expected" if none]

## 4. Invariants Touched
[List each invariant from INVARIANTS.md that this enhancement touches, enforces, or adds.
For each, state its scope tag and action:]

| INV-ID | Scope | Action | Notes |
|---|---|---|---|
| INV-XX | GLOBAL \| TASK-SCOPED | TOUCHES \| ENFORCES \| ADDS | |

Adding a GLOBAL invariant requires a Claude.md Section 2 amendment (see Section 5).
Adding a TASK-SCOPED invariant requires embedding in EXECUTION_PLAN.md task prompts — no Claude.md amendment.
State "No invariant impact" if none — not blank.

## 5. Claude.md Impact
**Version bump required:** YES | NO
**Reason:** [if YES — what changes and why]

A version bump is required when: a new GLOBAL invariant is added, the scope boundary
changes, or a new prohibited behaviour is defined. Adding only TASK-SCOPED invariants
does not require a Claude.md version bump.

## 6. Sign-Off Tier

**Tier:** [ 1 | 2 | 3 ]

Decision criteria:
- Tier 1: Type A, single session, no invariant additions, no schema changes,
  no Claude.md version bump
- Tier 2: Type A multi-session OR invariant enforcement point changes
  (not new invariants — changes to how existing invariants are enforced or documented)
- Tier 3: Type B (new invariants, schema changes, or Claude.md version bump).
  New GLOBAL invariants require a Claude.md Section 2 amendment. New TASK-SCOPED
  invariants do not — but the enhancement is still Tier 3 and requires a full
  invariant sweep.

**Part 1 sign-off artifact:**
- Tier 1: Session Log engineer sign-off + all Verification Record verdicts PASS
- Tier 2: ENH-NNN_VERIFICATION_CHECKLIST.md — changed invariants only
- Tier 3: ENH-NNN_VERIFICATION_CHECKLIST.md — full invariant sweep for touched INVs

BCE Close-Out (Part 2B) triggers on Part 1 sign-off regardless of tier.

**Tier change rule:** If the tier changes during build, update this field and
re-declare before the session continues. Do not proceed with a stale tier declaration.

## 7. Phase 3 Gate — Tier Reconfirmation

**Trigger:** Engineer runs this check before beginning Phase 3 (execution planning).
**Tool:** CD — as part of the Phase 3 gate conversation.

Before proceeding to Phase 3, confirm the following in CD:

[ ] The Sign-Off Tier declared in Section 6 remains appropriate given
    what Phases 1 and 2 surfaced.

If the Tier is unchanged: check the box and proceed to Phase 3.

If the Tier has changed: update Section 6 of this document with the
new Tier, the updated decision criteria, and the updated Part 1
sign-off artifact before proceeding. Record the reason for the
change below.

**Tier change record (leave blank if unchanged):**
Previous Tier: [  ]
New Tier: [  ]
Reason: [what surfaced in Phases 1–2 that changed the assessment]
Date updated: [date]

**Reconfirmation sign-off:** [name] — [date]

## 8. Engineer Sign-Off (Scoping Gate)
I confirm the scope, BCE impact, invariant assessment, and Sign-Off Tier above are
accurate to my current understanding before build begins.

**Signature:** [engineer name]
**Date:** [YYYY-MM-DD]
```

---

## Template 4 — Enhancement Brief (ENH-NNN_BRIEF.md)

**When to generate:** When an enhancement is created in the backlog. Brief matures over time.
**Review gate:** Brief review gate (Prompt 1) must pass and engineer must sign off
before brief can be included in Sprint Manifest analysis.
**Leave blank:** AI Review and Sign-Off status until gate passes.

```markdown
# ENH-NNN_BRIEF.md

**Enhancement ID:** ENH-NNN
**Title:** [Short title]
**Author:** [Engineer name]
**Date:** [Date authored]
**Status:** [ ] Draft | [ ] AI Review Complete | [ ] Signed Off

---

## Enhancement Intent
[One paragraph — plain language, what this enhancement does and why.
Not a technical specification. Legible to any engineer on the team.]

---

## Known Touch Points
[Modules, schema tables, API routes this enhancement is expected to touch.
Terminology must resolve against BCE artifact entries where possible.]

| Touch Point | BCE Artifact | Entry |
|---|---|---|
| [e.g. token ledger table] | TOPOLOGY.md | [e.g. schema/token_ledger] |

---

## Known Constraints
[Label each constraint MANDATORY or OPTIONAL.]

| Constraint | Type | Notes |
|---|---|---|
| [e.g. must not modify existing auth flow] | MANDATORY | [reason] |
| [e.g. prefer existing middleware pattern] | OPTIONAL | [can be revisited in Phase 1] |

---

## Out of Scope
[Explicit statement of what this enhancement will not touch. Not "TBD."]

---

## Engineer Sign-Off
[ ] I confirm this brief is accurate to my current understanding.
    Phase 1 may surface new information not reflected here.

**Signed:** [Engineer name]
**Date:** [Date]
```

---

## Template 5 — Sprint Manifest (SPRINT-NNN_MANIFEST.md)

**When to generate:** Sprint Lead produces this from adjudicated collision surface analysis.
Produced in CD using Prompt 2 then Prompt 3. Committed before any Phase 1 begins.
**Leave blank:** Sprint Lead sign-off until adjudication is complete.

```markdown
# SPRINT-NNN_MANIFEST.md

**Sprint ID:** SPRINT-NNN
**Timebox:** [Start date] → [End date]
**Sprint Lead:** [Name]
**Status:** [ ] Draft | [ ] Committed

---

## Enhancement List

| ENH ID | Title | Classification | Depends On |
|---|---|---|---|
| ENH-NNN | [title] | FOUNDATION / DEPENDENT / INDEPENDENT | ENH-NNN or blank |

---

## Dependency Graph

[Written description of all Foundation → Dependent relationships.
Independent enhancements listed separately.
Multiple Foundation tracks listed as parallel chains.
Any chain deeper than one level must be resolved before commit.]

**Chain depth validation:**
[ ] PASS — no chains deeper than one level
[ ] VIOLATION — [detail which chain and resolution required]

---

## Collision Surface Map

[One block per enhancement pair with any identified collision.
Pairs with no collision are not listed.]

### ENH-NNN × ENH-NNN

**Collision type:** BUILD-TIME | CLOSE-OUT
**Confidence:** DEFINITE | PROBABLE | NOT-DETECTABLE
**Surface:** [Named, locatable BCE artifact entry —
             e.g. MODULE_CONTRACTS.md → AuthMiddleware]
**ENH-NNN intent:** [what this enhancement intends to do with this surface]
**ENH-NNN intent:** [what this enhancement intends to do with this surface]
**Conflict nature:** [why these intents conflict or may conflict]
**Ownership:** [ENH-NNN owns this surface] |
               [Close-out reconciliation — no build-time owner]
**Sprint Lead adjudication:** [Confirmed / Downgraded to PROBABLE /
                               Downgraded to NOT-DETECTABLE / Ruled out]
**Notes:** [Sprint Lead adjudication rationale]

---

## Watchpoints

[Not-detectable surfaces assigned to specific engineers for Phase 1 confirmation.
Each watchpoint is a mandatory Phase 1 confirmation task — not optional monitoring.]

| ID | Enhancement | Surface | What Phase 1 Must Confirm | Assigned To |
|---|---|---|---|---|
| WP-001 | ENH-NNN | [BCE artifact entry] | [specific question] | [engineer] |

---

## Close-Out Reconciliation Items

[Enhancements sharing a BCE artifact section — Sprint Lead reconciles at close-out.]

| ENH IDs | BCE Artifact | Section | Nature of Overlap |
|---|---|---|---|
| ENH-NNN × ENH-NNN | [artifact] | [section] | [description] |

---

## Sprint Scope Validation

**Chain depth:** [ ] PASS | [ ] VIOLATION — [details]
**Foundation loop risk:**
[ ] Low — all Foundation enhancements are shallow and well-scoped
[ ] Flagged — [which Foundation, why, Sprint Lead risk determination]

---

## Sprint Lead Sign-Off

[ ] All Enhancement Briefs signed off — brief review gate passed for each
[ ] All briefs included in analysis — unsigned briefs identified and excluded
[ ] Collision surface analysis complete — all enhancement pairs reviewed
[ ] All DEFINITE and PROBABLE build-time collisions have ownership assignments
[ ] Chain depth rule satisfied — no chains deeper than one level
[ ] Watchpoints assigned to responsible engineers
[ ] Close-out reconciliation items recorded
[ ] ENH-NNN_SPRINT_CONSTRAINTS.md produced and reviewed for each building engineer
[ ] PROJECT_MANIFEST.md updated — all sprint and enhancement artifacts registered

**Signed:** [Sprint Lead name]
**Date:** [Date]
```

---

## Template 6 — Sprint Log (SPRINT-NNN_LOG.md)

**When to generate:** At sprint initiation. Sprint Lead maintains throughout sprint.
**Pre-populate:** Enhancement list from Sprint Manifest.
**Leave blank:** All event log entries, sync points, integration check results, close-out until they occur.

```markdown
# SPRINT-NNN_LOG.md

**Sprint ID:** SPRINT-NNN
**Timebox:** [Start date] → [End date]
**Sprint Lead:** [Name]
**Status:** OPEN | INTEGRATION CHECK | CLOSED

## Enhancements

| ENH ID | Title | Classification | Depends On | Engineer |
|---|---|---|---|---|
| ENH-NNN | [title] | FOUNDATION / DEPENDENT / INDEPENDENT | ENH-NNN or blank | [name] |

---

## Pre-Sprint Record

**Sprint Manifest committed:** [ ] Yes — Date: [date]
**PROJECT_MANIFEST.md updated:** [ ] Yes
**ENH-NNN_SPRINT_CONSTRAINTS.md distributed:** [ ] Yes

| ENH ID | SPRINT_CONSTRAINTS.md distributed | Engineer confirmed receipt |
|---|---|---|
| ENH-NNN | [ ] Yes | [ ] Yes |

---

## Sync Points

### Sync Point 1 — Foundation Claude.md Committed

[One entry per Foundation track.]

**Foundation ENH ID:** ENH-NNN
**Date committed:** [date]
**Claude.md version:** [version]
**Dependents cleared for Phase 3:** [ENH-NNN list or N/A]
**Sprint Lead confirmation:** [ ] Recorded

---

## Event Log

[Running record of sprint events. Add entries as they occur. Leave empty if none.]

### Event [N] — [STALL | RECLASSIFICATION | FOUNDATION AMENDMENT | LOOP]

**Date:** [date]
**Enhancement(s) affected:** ENH-NNN
**Description:** [What happened]
**Sprint Lead assessment:** [Determination and rationale]
**Dependents suspended:** [ENH-NNN list or NONE]
**Dependents cleared:** [Date cleared or PENDING]
**Action taken:** [What was done]

---

## Sprint Integration Check

**Trigger:** All Phase 8 Part 1 sign-offs complete
**Date:** [date]
**Sprint Lead:** [name]

**All Phase 8 Part 1 sign-offs confirmed:**

| ENH ID | Sign-Off Tier | Sign-Off Artifact | Confirmed |
|---|---|---|---|
| ENH-NNN | Tier 1 / 2 / 3 | [artifact] | [ ] Yes |

### Interaction Invariant Identification

**Combined change surface reviewed in CD:** [ ] Yes | [ ] Not required (single-enhancement sprint)

| Interaction Invariant | Enhancement Combination | Accepted |
|---|---|---|
| [invariant description] | ENH-NNN + ENH-NNN | [ ] Yes |

### Invariant Verification

Run in CC against fully assembled, running stack.

| Invariant | Source | ENH Scope Doc | Result |
|---|---|---|---|
| [invariant] | DECLARED / INTERACTION | ENH-NNN_SCOPE.md | PASS / FAIL |

### Failures

[Leave empty if all invariants PASS.]

| Failing Invariant | Affected Enhancement(s) | Loop Re-Entry Phase | Resolution Owner |
|---|---|---|---|

### Outcome

[ ] All invariants PASS — sprint close-out may begin
[ ] FAIL — loop re-entered, sprint boundary extended, close-out blocked

**Sprint Lead sign-off:**
**Date:**

---

## Sprint Close-Out

**Trigger:** Sprint Integration Check passed and signed off

**Steps completed:**

[ ] All enhancements merged to sprint branch
[ ] All ENH-NNN_BCE_IMPACT.md logs signed off — confirmed before BCE refresh begins
[ ] BCE refresh complete in CC — [N] artifacts updated
[ ] Conflicts resolved — [N] conflicts identified, all resolved with Sprint Lead judgment
[ ] ANNOTATION_CHECKLIST.md updated
[ ] Single sprint close-out commit to discovery/ — commit hash: [hash]
[ ] CD project files updated — all seven BCE artifacts uploaded
[ ] REGISTRY.md updated — all enhancements COMPLETE, sprint status CLOSED

**Close-out date:** [date]
**Sprint Lead sign-off:** [name]
```

---

## Template 7 — ENH-NNN_SPRINT_CONSTRAINTS.md

**When to generate:** Sprint Lead produces this for each building engineer after manifest adjudication.
Generated in CD using Prompt 3. Sprint Lead reviews before distributing.
**Leave blank:** Nothing — this is a complete reference document when generated.

```markdown
# ENH-NNN_SPRINT_CONSTRAINTS.md

**Enhancement ID:** ENH-NNN
**Title:** [Enhancement title]
**Sprint:** SPRINT-NNN
**Engineer:** [Name]
**Classification:** FOUNDATION | DEPENDENT | INDEPENDENT
**Produced by:** Sprint Lead from SPRINT-NNN_MANIFEST.md
**Date:** [Date]

---

## Your Classification

**Role:** [FOUNDATION | DEPENDENT | INDEPENDENT]

[One paragraph plain-language explanation of what this classification
means for this engineer in this sprint — what they can begin immediately,
what they must wait for, what they own, what they must not touch.
Must be unambiguous without opening the manifest.]

---

## Surfaces You Own

[Build-time surfaces this enhancement owns. Other enhancements will not touch these.
If no owned surfaces: state explicitly "No owned surfaces."]

| Surface | BCE Artifact Entry | Conflict Avoided |
|---|---|---|
| [e.g. AuthMiddleware] | MODULE_CONTRACTS.md → AuthMiddleware | ENH-NNN will not touch this |

---

## Surfaces You Must Not Touch

[Build-time surfaces owned by other enhancements.
Touching these without Sprint Lead escalation is a process violation.
If none: state explicitly "No restricted surfaces for this sprint."]

| Surface | BCE Artifact Entry | Owned By |
|---|---|---|
| [e.g. token_ledger schema] | TOPOLOGY.md → schema/token_ledger | ENH-NNN |

---

## Your Phase 3 Gate

[DEPENDENT enhancements only. Leave blank for FOUNDATION and INDEPENDENT
with note: "Not applicable — [FOUNDATION/INDEPENDENT] classification."]

**You may not begin Phase 3 until:**
[ ] Foundation ENH-NNN Claude.md committed and frozen — Sync Point 1 recorded
[List all Foundation enhancements this enhancement depends on.]

**Planning inputs available at Phase 3:**
- Frozen `discovery/` BCE artifacts
- Foundation ENH-NNN Claude.md
- Foundation ENH-NNN draft BCE impact log [advisory — subject to amendment per GAP4 protocol]

---

## Your Watchpoints

[Phase 1 confirmation tasks assigned from the Sprint Manifest.
Mandatory — not optional monitoring. Escalate to Sprint Lead immediately if confirmed.]

| ID | Surface | What You Must Confirm in Phase 1 | Escalate If |
|---|---|---|---|
| WP-001 | [surface] | [specific question] | [collision confirmed] |

---

## BCE Constraints

**Do not update `discovery/` artifacts during your enhancement build or close-out.**

Your per-enhancement BCE deliverable is `ENH-NNN_BCE_IMPACT.md` only — produced at
Phase 8 Part 2B close-out. Updating `discovery/` for a single enhancement mid-sprint
is a process violation. Record BCE knowledge in Verification Record BCE Impact sections
and in `ENH-NNN_BCE_IMPACT.md`. The Sprint Lead reconciles all impact logs and updates
`discovery/` once at sprint close-out.

---

## Escalation Rules

1. Any Phase 1 discovery that surfaces a new collision not in the Sprint Manifest →
   stop planning, escalate to Sprint Lead immediately before continuing
2. Any watchpoint confirmed as a collision →
   stop planning, escalate to Sprint Lead immediately
3. Any build divergence requiring amendment to your BCE impact log →
   notify Sprint Lead unconditionally — do not self-assess downstream impact

---

## Sprint Lead Contact

**Sprint Lead:** [Name]
**SPRINT-NNN_MANIFEST.md:** `enhancements/SPRINT-NNN/SPRINT-NNN_MANIFEST.md`
**SPRINT-NNN_LOG.md:** `enhancements/SPRINT-NNN/SPRINT-NNN_LOG.md`
```

---

## Template 8 — Design Gate Record (docs/PHASE4_GATE_RECORD.md)

**When to generate:** After Phase 4 Step 1 structured plan review is complete, before
the Step 1 gate passes. The engineer fills this from the review session output.
**Pre-populate:** Nothing — engineer fills all sections from the Phase 4 review.
**Leave blank:** Dispositions, verdicts, and engineer sign-off.

```markdown
# PHASE4_GATE_RECORD.md — [Project Name]
**Date:** [date]
**Engineer:** [name]
**Review session:** [CD session reference or date]

---

## Section A — Evaluation Criteria

| # | Criterion | Source |
|---|---|---|
| 1 | | Invariant: [INV-N] / Universal |
| 2 | | |
| 3 | | |
| ... | | |

---

## Section B — Requirements Traceability

| Requirement | Architecture Component | Task | Coverage Rating |
|---|---|---|---|
| | | | FULLY MET / PARTIALLY MET / NOT ADDRESSED / CONTRADICTED |

---

## Section C — Adversarial Stress Test Findings

| Attack Vector | Finding | Severity | Recommendation |
|---|---|---|---|
| DATA | | | |
| INFRASTRUCTURE | | | |
| EXECUTION | | | |
| SECURITY | | | |
| ARCHITECTURE vs PLAN GAP | | | |

---

## Section D — Risk Register with Dispositions

| # | Finding | Severity | Requirement or Invariant Affected | Return to Phase | Recommendation | Disposition | Rationale |
|---|---|---|---|---|---|---|---|
| | | | | | | RESOLVE / ACCEPT | |

**Overall verdict:** APPROVE / CONDITIONAL APPROVE / REVISE AND RESUBMIT
**Top 3 blockers:** [list or "none"]
**Confidence level:** [0–100%]

---

## Engineer Sign-Off

**Step 1 gate:** PASS / FAIL
**All RESOLVE findings addressed:** YES / NO
**Verdict confirmed:** APPROVE / CONDITIONAL APPROVE
**Signed:** [name] — [date]
```
