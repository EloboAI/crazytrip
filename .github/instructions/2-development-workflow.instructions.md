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
- **CRITICAL**: BEFORE starting ANY work, update the issue status to "In progress" in the project using the GraphQL API (see section 6).

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

## 6. Project Status Management

**CRITICAL**: Update project status at EVERY key milestone:

### When Starting Work
Before implementing ANYTHING:
```bash
ISSUE_NUM=<issue_number>
PROJECT_ID="PVT_kwHOCi99Ic4BHjd7"
STATUS_FIELD_ID="PVTSSF_lAHOCi99Ic4BHjd7zg4RobA"
IN_PROGRESS_ID="47fc9ee4"

NODE_ID=$(./gh api repos/EloboAI/crazytrip/issues/$ISSUE_NUM --jq '.node_id')
ITEM_RESULT=$(./gh api graphql -f query="mutation { addProjectV2ItemById(input: {projectId: \"$PROJECT_ID\" contentId: \"$NODE_ID\"}) { item { id } } }")
PROJECT_ITEM_ID=$(echo "$ITEM_RESULT" | jq -r '.data.addProjectV2ItemById.item.id')
./gh api graphql -f query="mutation { updateProjectV2ItemFieldValue(input: {projectId: \"$PROJECT_ID\" itemId: \"$PROJECT_ITEM_ID\" fieldId: \"$STATUS_FIELD_ID\" value: {singleSelectOptionId: \"$IN_PROGRESS_ID\"}}) { projectV2Item { id } } }" > /dev/null
echo "✅ Status set to 'In progress'"
```

### When Requesting Review
After completing work but before developer verification:
```bash
IN_REVIEW_ID="4cc61d42"
./gh api graphql -f query="mutation { updateProjectV2ItemFieldValue(input: {projectId: \"$PROJECT_ID\" itemId: \"$PROJECT_ITEM_ID\" fieldId: \"$STATUS_FIELD_ID\" value: {singleSelectOptionId: \"$IN_REVIEW_ID\"}}) { projectV2Item { id } } }" > /dev/null
echo "✅ Status set to 'In review'"
```

### After Developer Confirms Completion
Only after developer verification:
```bash
DONE_ID="98236657"
./gh api graphql -f query="mutation { updateProjectV2ItemFieldValue(input: {projectId: \"$PROJECT_ID\" itemId: \"$PROJECT_ITEM_ID\" fieldId: \"$STATUS_FIELD_ID\" value: {singleSelectOptionId: \"$DONE_ID\"}}) { projectV2Item { id } } }" > /dev/null
echo "✅ Status set to 'Done'"
```

**Status Values:**
- `Backlog` (`f75ad846`): Not started
- `Ready` (`08afe404`): Ready to pick up
- `In progress` (`47fc9ee4`): Currently working
- `In review` (`4cc61d42`): Awaiting verification
- `Done` (`98236657`): Completed and verified

## 7. Working Within Scope
- **CRITICAL**: Implement ONLY ONE Task at a time. Never work on multiple Tasks simultaneously.
- **CRITICAL**: After completing a Task, STOP and ask the developer which Task to tackle next.
- Implement only what is in the CURRENT Task's title and technical tasks list.
- If you notice related work in other Tasks, mention it but DO NOT implement it.
- Reject or escalate out-of-scope requests: offer to switch issues, open a new one, or stay within scope.
- Keep code consistent with project standards (Theme colors, Material 3, existing widgets, accessibility, etc.).

## 8. During Implementation
- **CRITICAL**: At the START of EVERY action (file read, file edit, command execution), state: "**[Task #X]** - [Brief description of what you're doing]"
- **CRITICAL**: After EACH significant action (not just at the end), add a progress comment to the Task issue using `mcp_githubmcp_add_issue_comment`
- Use theme-aware colors and shared styles; never hardcode palette values.
- Test results in light and dark themes and cover edge cases relevant to the work item.
- Keep changes constrained to the affected feature; avoid broad refactors unless explicitly requested and approved.
- **CRITICAL**: As you complete technical subtasks within the Task, add comments documenting what was done.

## 9. Completion Flow

### 9.1 When Completing a Task
1. **CRITICAL**: When ALL technical tasks in the current Task are completed:
   a. Add a final completion comment to the Task issue
   b. Update project status to "In review" using the workflow in section 6
   c. Ask the developer to verify the implementation
   
2. **ONLY after developer confirms the Task is complete:**
   a. First, update the project Status to `Done`:
      ```bash
      # Get the project item ID if not already cached
      NODE_ID=$(./gh api repos/EloboAI/crazytrip/issues/$ISSUE_NUM --jq '.node_id')
      ITEM_RESULT=$(./gh api graphql -f query="mutation { addProjectV2ItemById(input: {projectId: \"PVT_kwHOCi99Ic4BHjd7\" contentId: \"$NODE_ID\"}) { item { id } } }")
      PROJECT_ITEM_ID=$(echo "$ITEM_RESULT" | jq -r '.data.addProjectV2ItemById.item.id')
      
      # Update to Done
      ./gh api graphql -f query="mutation { updateProjectV2ItemFieldValue(input: {projectId: \"PVT_kwHOCi99Ic4BHjd7\" itemId: \"$PROJECT_ITEM_ID\" fieldId: \"PVTSSF_lAHOCi99Ic4BHjd7zg4RobA\" value: {singleSelectOptionId: \"98236657\"}}) { projectV2Item { id } } }"
      ```
   
   b. Then close the Task issue:
      ```javascript
      mcp_githubmcp_issue_write({
        method: "update",
        owner: "EloboAI",
        repo: "crazytrip",
        issue_number: TASK_NUMBER,
        state: "closed",
        state_reason: "completed"
      })
      ```
   
   c. Check the corresponding acceptance criterion checkbox in the parent User Story

### 9.2 Checking Parent Closure
3. **After closing the Task:**
   a. Fetch all sibling Tasks using `mcp_githubmcp_issue_read({method:"get_sub_issues", owner:"EloboAI", repo:"crazytrip", issue_number:USER_STORY_NUMBER})`
   
   b. Check if ALL sibling Tasks are:
      - Closed (state = "closed")
      - Have status "Done" in the project
   
   c. Verify all acceptance criteria in the User Story are checked
   
   d. **If ALL conditions are met:**
      - Inform the developer: "All Tasks are complete and all acceptance criteria are met for User Story #X"
      - Ask: "Should I close User Story #X and update its status to Done?"
      - Wait for confirmation
   
   e. **If ANY condition is not met:**
      - List which Tasks are still open or not Done
      - List which acceptance criteria are not checked
      - Do NOT suggest closing the User Story

### 9.3 Closing Parent Issues
4. **When closing a User Story (after ALL Tasks are Done):**
   a. Update User Story status to "Done" in project
   b. Close User Story issue with `state_reason: "completed"`
   c. Fetch all sibling User Stories from parent Feature
   d. Check if ALL sibling User Stories are closed and Done
   e. If yes, ask developer if Feature should be closed
   f. If no, report which User Stories remain open

5. **When closing a Feature (after ALL User Stories are Done):**
   a. Update Feature status to "Done" in project
   b. Close Feature issue with `state_reason: "completed"`
   c. Fetch all sibling Features from parent Epic
   d. Check if ALL sibling Features are closed and Done
   e. If yes, ask developer if Epic should be closed
   f. If no, report which Features remain open

### 9.4 General Rules
6. **CRITICAL**: Never close multiple issues in one turn. Close one Task, check parent, then ask developer what's next.
7. **CRITICAL**: Never close a parent issue without developer confirmation, even if all children are complete.
8. Always communicate what was closed, what remains open, and suggest the next logical Task with rationale.

## 10. Communication Reference
- **CRITICAL**: Always prefix your actions with the Task number: "**[Task #X]** - Action description"
- Report progress after EACH significant action, not just at the end
- After finishing a Task and closing it, list outstanding Tasks from the same User Story
- Recommend the next Task with reasoning (dependencies, logical order)
- If blocked or out of scope, explain the reason and offer concrete options.
- **CRITICAL**: Keep the developer informed throughout the process, not just at the beginning and end

## 11. Critical Rules
1. Always ask for the work item first and read it fully.
2. Always create missing Tasks for User Stories before coding.
3. Always analyze Tasks to determine if they are fully manual, fully automated, or partially manual.
4. Always add detailed comments to issues with manual steps that lack clear instructions.
5. For partially manual Tasks, always wait for developer to complete manual parts before proceeding with automated parts.
6. Always validate dependencies (blocked issues, sibling Tasks/User Stories, manual prerequisites).
7. Always ensure the issue is in the correct iteration before starting.
8. Always respect scope; escalate anything outside it.
9. **CRITICAL**: Always work on ONE Task at a time. Never implement multiple Tasks without explicit developer approval.
10. **CRITICAL**: Always prefix actions with "**[Task #X]**" so developer knows what you're working on.
11. **CRITICAL**: Always add progress comments to the Task issue as you work, not just at the end.
12. **CRITICAL**: Always update project status in this order: "In progress" → work → "In review" → developer confirms → "Done" → close issue.
13. **CRITICAL**: Always update project status to Done BEFORE closing the issue.
14. **CRITICAL**: After closing ANY issue, check if ALL sibling issues are closed and Done before suggesting to close the parent.
15. **CRITICAL**: Never close a parent issue without explicit developer confirmation, even if all children are complete.
16. Always communicate next steps and rationale after completing work.
17. Always use `./gh` for GitHub CLI calls and keep command usage transparent.
18. Never proceed when blocked, misaligned, out of scope, or missing manual prerequisites.
19. Never assume a Task is fully automated—always read ALL technical tasks and categorize each one.
