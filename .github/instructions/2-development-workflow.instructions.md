---
applyTo: "**"
---

# Development Workflow Instructions

> Reference the API commands and hierarchy rules in `./.github/instructions/1-github-api-reference.instructions.md` when needed.

## 1. Entry Checklist
- Always ask the developer which issue to tackle before doing anything else.
- Fetch the issue with `./gh api repos/EloboAI/crazytrip/issues/<number>` and read title, body, parent reference, acceptance criteria, and technical tasks.
- Work only inside GitHub issues (Epic → Feature → User Story → Task). Never code without an explicit issue.
- **CRITICAL**: After fetching the issue, ALWAYS analyze it completely BEFORE listing options or asking which task to do.

## 2. User Stories vs Tasks
**When the chosen issue is a User Story:**
- Ensure it already has Tasks (one per acceptance criterion). If any criterion lacks a Task, create it immediately, linking back to the User Story and using the parent Feature label.
- **BEFORE asking which Task to start**: Analyze ALL Tasks for manual actions and dependencies.
- **Create ALL required [MANUAL] Tasks FIRST** before presenting options to the developer.
- After manual Tasks are created and identified, present the developer with:
  1. List of manual Tasks with direct GitHub links that need completion first
  2. List of automated Tasks in recommended execution order
  3. Clear explanation of dependencies between tasks
- Wait for developer to confirm manual Tasks are done before proceeding with automated Tasks.

**When the chosen issue is a Task:**
- Confirm the parent User Story via the `**Parent:** #<id>` header.
- Compare the Task scope with the parent's acceptance criteria. If it does not match, stop and clarify.
- Gather sibling Tasks with `mcp_githubmcp_issue_read({method:"get_sub_issues", ...})` and note their status for dependency checks.
- **IMMEDIATELY check if this Task requires manual actions** (API keys, credentials, OAuth setup, etc.).
- If manual actions are required, create a `[MANUAL]` Task, show the link to the developer, and STOP until they complete it.

## 3. Manual Actions
- **ALWAYS check FIRST if the Task requires manual actions** before attempting to code anything.
- If completing the Task requires anything the assistant cannot do (API keys, OAuth, certificates, hardware tests, billing configuration, cloud console setup, etc.), create a new `[Task] [MANUAL] ...` issue IMMEDIATELY.
- Manual Task rules:
  - Parent is always the User Story, not the current Task.
  - Labels: `manual-action`, `AI-requirement`, plus the parent Feature label.
  - Body includes purpose, exact steps (with concrete commands), resources, and a verification checklist.
  - Link it to the User Story with `addSubIssue`, add it to the project, set Type = Task, and assign it to the user.
  - **CRITICAL**: Show the developer the direct GitHub link to the manual Task in this format: `https://github.com/EloboAI/crazytrip/issues/<number>`
  - Explain clearly what needs to be done manually and why the assistant cannot do it.
  - **STOP and wait** until the developer confirms completion and marks the manual Task as Done in the project.

### Common Manual Actions That Require [MANUAL] Tasks:
- Obtaining API keys from cloud providers (Google Cloud, AWS, Firebase, etc.)
- OAuth application registration and client ID/secret generation
- SSL certificate generation or purchase
- Payment/billing setup in external services
- Hardware testing or physical device setup
- App store account creation or configuration
- Domain registration or DNS configuration
- Third-party service account creation
- Code signing certificates
- Environment secrets that cannot be committed to git

## 4. Dependency Validation
**For Tasks:**
- Verify alignment with parent acceptance criteria.
- Identify prerequisite sibling Tasks (setup before UI, models before data usage, etc.).
- If a dependency is missing, recommend tackling the prerequisite first and wait for confirmation.

**For User Stories:**
- Confirm the parent Feature is known and not blocked. Check the issue body for `Blocked by` lines and ensure blockers are closed and set to Done in the project.
- Review sibling User Stories for logical prerequisites (e.g., authentication before profile UI).
- If dependencies are unresolved, surface them and wait for direction.

## 5. Iteration Handling
- Every issue must belong to the current project iteration.
- If no iteration is set, automatically assign the current iteration using the IDs from the API reference.
- If it is in a different iteration, ask the developer whether to move it before changing anything.

## 6. Working Within Scope
- Implement only what is in the issue title, acceptance criteria, or technical tasks.
- Reject or escalate out-of-scope requests: offer to switch issues, open a new one, or stay within scope.
- Keep code consistent with project standards (Theme colors, Material 3, existing widgets, accessibility, etc.).

## 7. During Implementation
- Use theme-aware colors and shared styles; never hardcode palette values.
- Test results in light and dark themes and cover edge cases relevant to the work item.
- Keep changes constrained to the affected feature; avoid broad refactors unless explicitly requested and approved.

## 8. Completion Flow
1. Wait for the developer to confirm the work is finished.
2. Close the issue via `mcp_githubmcp_issue_write` (state = closed, state_reason = completed when appropriate).
3. Update the project Status field to `Done` using the provided field/option IDs.
4. Review parent links:
   - For Tasks: if all sibling Tasks are closed and criteria met, close the User Story.
   - For User Stories: if all siblings are closed, close the Feature.
   - Apply the same logic recursively up the hierarchy.
5. Communicate what closed, what remains open, and suggest the next logical Task/User Story with a short rationale.

## 9. Communication Reference
- Report progress succinctly, highlighting status of parents and remaining siblings when relevant.
- After finishing a Task, list outstanding Tasks from the same User Story and recommend an order (with reasoning) so the developer can pick the next item.
- If blocked or out of scope, explain the reason and offer concrete options.

## 10. Critical Rules
1. Always ask for the work item first and read it fully.
2. Always create missing Tasks for User Stories before coding.
3. Always create manual Tasks for user-only actions and stop until they finish them.
4. Always validate dependencies (blocked issues, sibling Tasks/User Stories, manual prerequisites).
5. Always ensure the issue is in the correct iteration before starting.
6. Always respect scope; escalate anything outside it.
7. Always close issues only after explicit developer confirmation and status updates in the project.
8. Always communicate next steps and rationale after completing work.
9. Always use `./gh` for GitHub CLI calls and keep command usage transparent.
10. Never proceed when blocked, misaligned, out of scope, or missing manual prerequisites.
