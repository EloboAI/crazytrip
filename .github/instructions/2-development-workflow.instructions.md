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
- **BEFORE presenting any response to the developer:**
  1. Fetch ALL existing Tasks using `mcp_githubmcp_issue_read({method:"get_sub_issues", ...})`
  2. Analyze EACH Task to identify its manual/automated nature:
     - Read the full Task description and technical tasks
     - Classify each technical subtask as Manual (✋), Automated (🤖), or Blocked (⚠️)
     - For Tasks with manual steps that lack clear instructions, add a detailed comment using `mcp_githubmcp_add_issue_comment`
  3. Categorize Tasks as:
     - **Fully Manual**: All steps require developer action
     - **Fully Automated**: All steps can be done by agent
     - **Partially Manual**: Mix of manual and automated steps
  4. Create NEW `[MANUAL]` Tasks ONLY if manual work is needed but no existing Task covers it
- **After analyzing all Tasks, present the developer with ONE response that includes:**
  1. **Fully Manual Tasks** with direct GitHub links: `https://github.com/EloboAI/crazytrip/issues/<number>`
  2. **Partially Manual Tasks** with:
     - Link to the issue (with your comment if you added one)
     - Summary of manual steps they must do first
     - Summary of automated steps you'll do after
  3. **Fully Automated Tasks** in recommended execution order with their issue numbers
  4. Clear explanation of dependencies between tasks
- **CRITICAL**: Do NOT give multiple responses or mention issue numbers before creating them. Complete all analysis, comment addition, and Task creation FIRST, then present everything in ONE single response.
- Wait for developer to confirm manual parts are done before proceeding with automated parts.

**When the chosen issue is a Task:**
- Confirm the parent User Story via the `**Parent:** #<id>` header.
- Compare the Task scope with the parent's acceptance criteria. If it does not match, stop and clarify.
- Gather sibling Tasks with `mcp_githubmcp_issue_read({method:"get_sub_issues", ...})` and note their status for dependency checks.
- **IMMEDIATELY analyze if this Task is fully manual, fully automated, or partially manual:**
  1. Read ALL technical tasks in the issue body
  2. Categorize each technical subtask (✋ Manual / 🤖 Automated / ⚠️ Blocked)
  3. If the Task has manual steps WITHOUT clear instructions, add a detailed comment with step-by-step guidance
- **If Task is FULLY MANUAL:**
  - Add clarifying comment if instructions are unclear
  - Show link to developer and STOP until they complete it
- **If Task is PARTIALLY MANUAL:**
  - Add comment breaking down manual vs automated steps (if not already clear)
  - Show link to developer with explanation of what they do first
  - WAIT for confirmation they completed manual parts
  - Then proceed with automated parts only
- **If Task is FULLY AUTOMATED:**
  - Check if any sibling Tasks have manual prerequisites that are incomplete
  - If blocked by manual work, inform developer and STOP
  - If not blocked, proceed with implementation
- If no existing Task covers required manual work, create a new `[MANUAL]` Task, show the link, and STOP until they complete it.

## 3. Manual Actions

### 3.1 Identifying Manual vs Automated Work
- **ALWAYS check FIRST if any Task requires manual actions** before attempting to code anything or presenting response.
- Manual actions are ANY work that the assistant CANNOT perform, including: API keys, OAuth, certificates, hardware tests, billing, cloud console setup, etc.
- **CRITICAL: Tasks can be FULLY MANUAL, FULLY AUTOMATED, or PARTIALLY MANUAL**
  - **Fully Manual**: All steps require human intervention (e.g., creating Google Cloud project, obtaining API key)
  - **Fully Automated**: All steps can be done by the agent (e.g., adding dependency to pubspec.yaml)
  - **Partially Manual**: Some steps are manual, others are automated (e.g., Task requires API key first, then agent configures it in code)

### 3.2 Analyzing Tasks for Manual Actions
**When analyzing Tasks:**
1. Read ALL technical tasks/subtasks in the issue body
2. Categorize EACH technical task as:
   - ✋ **Manual**: Requires developer action (can't be automated)
   - 🤖 **Automated**: Can be done by the agent
   - ⚠️ **Blocked**: Automated but depends on manual task completion
3. If the Task has ANY manual steps, add a comment to the issue with:
   - Clear breakdown of manual vs automated steps
   - Detailed instructions for manual steps (with commands, links, screenshots guidance)
   - Order of execution (what the developer does first, what the agent does after)
   - Verification checklist for the developer

### 3.3 Commenting on Tasks with Manual Steps
**When a Task contains manual steps that lack detailed instructions:**
- Use `mcp_githubmcp_add_issue_comment` to post a comment with:
  ```markdown
  ## 🔍 Análisis de Tareas Manual vs Automatizada
  
  ### ✋ Pasos Manuales (Requieren tu acción):
  1. **[Descripción del paso manual]**
     - Accede a [URL específica]
     - Haz clic en [acción específica]
     - Copia el valor de [campo específico]
     - Recursos: [enlaces a documentación oficial]
  
  2. **[Otro paso manual si aplica]**
     ...
  
  ### 🤖 Pasos Automatizados (Los haré yo después):
  1. Agregar la configuración al archivo X
  2. Actualizar el código en Y
  3. Verificar funcionamiento en Z
  
  ### 📋 Checklist de Verificación:
  - [ ] Obtuve el valor necesario de [fuente]
  - [ ] Verifiqué que [condición]
  - [ ] Confirmé que [resultado esperado]
  
  **Una vez completes los pasos manuales, confirma en este issue y procederé con los pasos automatizados.**
  ```

### 3.4 Working with Partially Manual Tasks
**Workflow for partially manual Tasks:**
1. Identify the Task is partially manual
2. Add detailed comment (as described in 3.3) if instructions are missing or unclear
3. Present to developer:
   - Link to the issue with your comment
   - Summary of what they need to do
   - What you'll do automatically after
4. **WAIT** for developer confirmation before proceeding with automated parts
5. Once confirmed, execute only the automated steps
6. Request verification of the complete Task

### 3.5 Creating New Manual Tasks
- Create a NEW `[Task] [MANUAL] ...` issue ONLY if:
  - Manual work is needed but no existing Task covers it
  - The manual work is substantial enough to warrant a separate Task
  - The manual work is NOT just a prerequisite step of an existing Task
- Manual Task rules:
  - Parent is always the User Story, not the current Task
  - Labels: `manual-action`, `AI-requirement`, plus the parent Feature label
  - Body includes purpose, exact steps (with concrete commands), resources, and verification checklist
  - Link it to the User Story with `addSubIssue`, add it to the project, set Type = Task, and assign it to the user
  - **CRITICAL**: Show the developer the direct GitHub link in this format: `https://github.com/EloboAI/crazytrip/issues/<number>`
  - Explain clearly what needs to be done manually and why the assistant cannot do it
  - **STOP and wait** until the developer confirms completion and marks the manual Task as Done in the project

### 3.6 Common Manual Actions
Actions that ALWAYS require human intervention:
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
- Enabling APIs in cloud consoles
- Setting up billing accounts
- Creating service accounts with specific permissions
- Verifying domain ownership

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
3. Always analyze Tasks to determine if they are fully manual, fully automated, or partially manual.
4. Always add detailed comments to issues with manual steps that lack clear instructions.
5. For partially manual Tasks, always wait for developer to complete manual parts before proceeding with automated parts.
6. Always validate dependencies (blocked issues, sibling Tasks/User Stories, manual prerequisites).
7. Always ensure the issue is in the correct iteration before starting.
8. Always respect scope; escalate anything outside it.
9. Always close issues only after explicit developer confirmation and status updates in the project.
10. Always communicate next steps and rationale after completing work.
11. Always use `./gh` for GitHub CLI calls and keep command usage transparent.
12. Never proceed when blocked, misaligned, out of scope, or missing manual prerequisites.
13. Never assume a Task is fully automated—always read ALL technical tasks and categorize each one.
