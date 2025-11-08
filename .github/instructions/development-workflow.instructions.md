---
applyTo: "**"
---

# Development Workflow Instructions

## Execution Preferences

**Preferred approach**: Execute commands directly in the terminal instead of creating script files.

- ✅ **DO**: Copy and execute commands directly in terminal
- ✅ **DO**: Use loops and functions inline for batch operations
- ❌ **AVOID**: Creating script files unless processing 20+ items or for reusable automation
- ❌ **AVOID**: Creating files for one-time operations

> **Note**: Only create script files when explicitly needed for large batch operations or when the developer requests a reusable automation.

## Starting Work

### 1. Always Request a Work Item

Before starting any development work, **ALWAYS** ask the developer which work item they want to work on:

```
"¿En qué work item (issue) quieres trabajar? Por favor proporciona el número del issue."
```

❌ **NEVER** start coding without a specific work item assigned
✅ **ALWAYS** work within the context of a GitHub issue (Task, User Story, or Feature)

### 2. Read Work Item Details

Once you have the issue number, retrieve and analyze:

```bash
./gh api repos/EloboAI/crazytrip/issues/<number>
```

**Extract and understand:**
- **Title**: What needs to be implemented
- **Description**: Detailed requirements and context
- **Parent reference**: Check if there's a `**Parent:** #<number>` at the top
- **Criterios de Aceptación** (for User Stories): Clear checklist of what must be completed
- **Tareas Técnicas** (for Tasks): Specific implementation steps

### 3. Verify and Create Tasks (User Stories Only)

**CRITICAL**: If the work item is a User Story (type = "user story"), you MUST verify it has Tasks before starting development.

#### Step 1: Check if User Story has Tasks

```javascript
mcp_githubmcp_issue_read({
  method: "get_sub_issues",
  owner: "EloboAI",
  repo: "crazytrip",
  issue_number: <user_story_number>
})
```

#### Step 2: Evaluate Task Status

✅ **If Tasks exist and some are open:**
- List all Tasks with their status
- Ask developer which Task to work on
- Proceed with selected Task

✅ **If ALL Tasks are closed:**
- Inform developer that all Tasks are complete
- Suggest closing the User Story

❌ **If NO Tasks exist:**
- **AUTOMATICALLY create Tasks** from acceptance criteria
- One Task per acceptance criterion
- Follow the pattern from `github-workflow.instructions.md`

#### Step 3: Create Missing Tasks

For each unchecked acceptance criterion (`- [ ]`), create a Task:

```javascript
// 1. Create the Task issue
mcp_githubmcp_issue_write({
  method: "create",
  owner: "EloboAI",
  repo: "crazytrip",
  title: "[Task] <imperative verb> <what>",
  body: `**Parent:** #<user_story_number>

**Descripción:** <acceptance criterion text>

**Tareas Técnicas:**
- <technical step 1>
- <technical step 2>
- <technical step 3>`,
  type: "task"
})

// 2. Get node IDs
const parentNodeId = await getNodeId(<user_story_number>)
const taskNodeId = await getNodeId(<new_task_number>)

// 3. Link Task to User Story via sub-issue API
./gh api graphql -f query='
mutation {
  addSubIssue(input: {
    issueId: "PARENT_NODE_ID"
    subIssueId: "TASK_NODE_ID"
  }) {
    subIssue {
      id
    }
  }
}'
```

#### Step 4: Inform Developer

After creating Tasks:
```
✅ User Story #<number> no tenía Tasks definidas
✅ Creadas <N> Tasks desde los criterios de aceptación:
   - Task #<number>: <title>
   - Task #<number>: <title>
   - Task #<number>: <title>

¿En cuál Task quieres que empiece a trabajar?
```

#### When to Skip Task Creation

❌ **NEVER create Tasks if:**
- Work item is NOT a User Story (it's a Task or Feature)
- User Story already has Tasks (even if all are closed)
- Acceptance criteria are missing or unclear

✅ **ALWAYS ask for clarification if:**
- Acceptance criteria are vague
- It's unclear how to split into Tasks
- Developer might want different Task breakdown

### 4. Validate Scope Before Starting

**CRITICAL**: Before starting any work, validate that the developer's request is within the scope of the work item:

✅ **If request is IN SCOPE:**
- The request matches the work item title
- The request is covered by the acceptance criteria or technical tasks
- The request is a clarification or refinement of existing requirements
→ **Proceed with development**

❌ **If request is OUT OF SCOPE:**
- The request adds functionality not listed in acceptance criteria
- The request modifies different features or components
- The request is unrelated to the work item's purpose
→ **STOP and inform the developer:**

```
⚠️ Lo que solicitas no está dentro del alcance del work item #<number>.

**Work item actual:** <title>
**Alcance definido:** 
- <list acceptance criteria or technical tasks>

**Tu solicitud:** <what they asked for>

**Opciones:**
1. Dame otro work item que cubra esta funcionalidad
2. Solicita crear un nuevo issue para esta tarea
3. Trabajemos en lo que está definido en el work item actual

¿Cómo quieres proceder?
```

❌ **NEVER** implement features outside the defined scope without explicit approval
❌ **NEVER** assume that related functionality should be included
✅ **ALWAYS** stick to the exact requirements in the work item
✅ **ALWAYS** ask for clarification if the scope is unclear

### 5. Mark Task as In Progress

Before starting development, update the task state to communicate you're working on it:

```javascript
mcp_githubmcp_issue_write({
  method: "update",
  owner: "EloboAI",
  repo: "crazytrip",
  issue_number: <number>,
  // Add comment or update to indicate work started
})
```

Or add a comment:
```javascript
mcp_githubmcp_add_issue_comment({
  owner: "EloboAI",
  repo: "crazytrip",
  issue_number: <number>,
  body: "🚀 Iniciando trabajo en esta tarea"
})
```

## During Development

### Stay Within Scope

**CRITICAL RULE**: Only implement what is explicitly defined in the work item.

✅ **Allowed within scope:**
- Implementing listed acceptance criteria
- Following technical tasks as described
- Bug fixes directly related to the work item
- Code quality improvements for the specific feature
- Asking clarifying questions about requirements

❌ **NOT allowed without approval:**
- Adding features not in acceptance criteria
- Modifying unrelated components
- Implementing "nice to have" additions
- Refactoring code outside the work item scope
- Creating new functionality not described

**If developer asks for out-of-scope work during development:**
```
⚠️ Esto no está en el alcance del work item #<number> actual.

¿Quieres que:
1. Continúe con el work item actual (#<number>)
2. Me des un work item diferente que cubra esto
3. Cree un nuevo issue para esta funcionalidad

```

### Follow Acceptance Criteria

**For User Stories:**
- Implement ALL acceptance criteria listed in the issue
- Each checkbox must be validated and checked off when complete
- Don't add features not listed in acceptance criteria without asking

**For Tasks:**
- Follow the technical tasks listed in the issue description
- Implement exactly what's described
- Ask for clarification if requirements are unclear

### Code Quality Standards

When implementing features:
1. ✅ Use theme-aware colors from `Theme.of(context).colorScheme`
2. ✅ Never hardcode colors (e.g., avoid `Colors.grey`, use `colorScheme.outline`)
3. ✅ Follow Material Design 3 guidelines
4. ✅ Test in both light and dark modes
5. ✅ Ensure proper contrast and accessibility
6. ✅ Use existing widgets and components when available
7. ✅ Follow the established project structure

### Testing Requirements

Before marking work as complete:
- ✅ Test the implemented functionality thoroughly
- ✅ Verify all acceptance criteria are met
- ✅ Test edge cases and error scenarios
- ✅ Check visual appearance in both themes (if UI work)
- ✅ Ensure no regressions in existing functionality

## Completing Work

### 1. Developer Confirmation

Wait for the developer to confirm the work is complete. Look for phrases like:
- "Ya está listo"
- "Terminé"
- "Está completo"
- "Ya quedó"

❌ **DON'T** assume work is done just because you made changes
✅ **WAIT** for explicit confirmation from the developer

### 2. Mark Task as Completed

Once developer confirms, close the task with `completed` state reason:

```javascript
mcp_githubmcp_issue_write({
  method: "update",
  owner: "EloboAI",
  repo: "crazytrip",
  issue_number: <number>,
  state: "closed",
  state_reason: "completed"
})
```

### 3. Check Parent and Siblings

After closing a task, **ALWAYS** check for parent-child relationships:

#### Get Parent Issue Number
Look for `**Parent:** #<number>` in the task description.

#### Get All Sub-Issues of Parent
```javascript
mcp_githubmcp_issue_read({
  issue_number: <parent_number>,
  method: "get_sub_issues",
  owner: "EloboAI",
  repo: "crazytrip"
})
```

#### Verify All Siblings are Complete
Check the state of all sub-issues:
- If ALL sub-issues are `closed` with `state_reason: "completed"`
- AND all acceptance criteria in parent are checked (`[x]`)
- THEN proceed to close the parent

### 4. Close Parent if Complete

**For User Stories:**
```javascript
mcp_githubmcp_issue_write({
  method: "update",
  owner: "EloboAI",
  repo: "crazytrip",
  issue_number: <parent_number>,
  state: "closed",
  state_reason: "completed"
})
```

**Inform the developer:**
```
✅ Task #<number> completada
✅ Todos los sub-issues del User Story #<parent> están completos
✅ User Story #<parent> cerrado como completado
```

### 5. Repeat for Higher Levels

If the parent was a User Story with a Feature parent:
1. Check if ALL sibling User Stories are complete
2. If yes, close the Feature
3. Report completion status up the hierarchy

## Work Item Hierarchy Validation

### Before Closing Any Issue

Always validate:
```bash
# 1. Get the issue details
./gh api repos/EloboAI/crazytrip/issues/<number>

# 2. Check for parent reference in body
# Look for: **Parent:** #<number>

# 3. If parent exists, get all its sub-issues
# Use mcp_githubmcp_issue_read with method "get_sub_issues"

# 4. Verify ALL siblings are closed
# Only close parent if ALL children are completed
```

### Completion Checklist

Before closing any work item:
- [ ] Developer explicitly confirmed work is complete
- [ ] All acceptance criteria are verified (if User Story)
- [ ] All technical tasks are implemented (if Task)
- [ ] Code has been tested in relevant scenarios
- [ ] Visual bugs reported by developer are fixed
- [ ] Parent issue identified (if exists)
- [ ] All sibling issues verified as complete (if parent exists)
- [ ] Parent closed if all siblings complete

## Common Scenarios

### Scenario 1: Task with No Parent
```
Developer: "Ya está lista la tarea #180"
You:
1. Close task #180 as completed
2. Report: "✅ Task #180 completada (sin parent)"
```

### Scenario 2: Task with Parent User Story
```
Developer: "Ya terminé el task #188"
You:
1. Close task #188 as completed
2. Check parent (e.g., #156)
3. Get all sub-issues of #156
4. If all sub-issues closed → Close #156
5. Report: "✅ Task #188 completada. User Story #156 cerrado (todos sus tasks completos)"
```

### Scenario 3: Last User Story of Feature
```
Developer: "Listo el user story #157"
You:
1. Verify all tasks of #157 are closed
2. Close #157 as completed
3. Check parent Feature (e.g., #38)
4. Get all sub-issues (User Stories) of #38
5. If all User Stories closed → Close Feature #38
6. Report: "✅ User Story #157 completado. Feature #38 cerrado (todos sus user stories completos)"
```

### Scenario 4: Work Not Complete
```
Developer: "Hay un bug en el dark mode"
You:
❌ DON'T close the task
✅ Continue working on fixes
✅ Ask: "¿Qué necesitas que corrija específicamente?"
```

### Scenario 5: Developer Requests Out-of-Scope Work
```
Developer working on #188 (Task: "Implementar toggle entre modo claro y oscuro")
Developer: "También implementa la persistencia del tema seleccionado"

You:
1. Check acceptance criteria of #188
2. If "persistencia" is NOT listed:
   ⚠️ La persistencia del tema no está en el alcance del Task #188.
   
   **Alcance actual (#188):**
   - Implementar toggle entre modo claro y oscuro
   
   **Tu solicitud:** Persistencia del tema
   
   ¿Quieres que:
   1. Busquemos otro task que incluya la persistencia
   2. Cree un nuevo issue para esta funcionalidad
   3. Continuemos solo con lo del task actual
```

### Scenario 6: Ambiguous Request Clarification
```
Developer: "Trabaja en el issue #156"
Developer: "Ahora agrega validación de formularios"

You:
1. Check #156 acceptance criteria
2. If validation is not mentioned:
   ⚠️ La validación de formularios no está mencionada en #156.
   
   ¿Esto es parte del issue actual o necesitas que trabaje en un issue diferente?
```

## Communication Guidelines

### Always Inform Progress

When closing work items, provide clear status:
```
✅ Task #<number> - <title> completada
📊 Estado del Parent #<parent>: <X>/<total> sub-issues completos
⏳ Pendientes: #<number>, #<number>
```

Or if everything is complete:
```
✅ Task #<number> completada
✅ User Story #<parent> completado (todos los tasks finalizados)
✅ Feature #<grandparent> completado (todos los user stories finalizados)
```

### Ask for Next Task

After completing work:
```
"Tarea completada. ¿En qué quieres que trabaje ahora?"
```

## Critical Rules

1. ✅ **ALWAYS** ask for work item number before starting
2. ✅ **ALWAYS** read and understand acceptance criteria
3. ✅ **ALWAYS** validate that requests are within scope
4. ✅ **ALWAYS** stop and ask if request is out of scope
5. ✅ **ALWAYS** wait for developer confirmation before closing
6. ✅ **ALWAYS** check parent-child relationships
7. ✅ **ALWAYS** verify all siblings before closing parent
8. ✅ **ALWAYS** use `state_reason: "completed"` when closing
9. ❌ **NEVER** implement features outside the defined scope
10. ❌ **NEVER** assume additional functionality should be included
11. ❌ **NEVER** close work items prematurely
12. ❌ **NEVER** skip hierarchy validation
13. ❌ **NEVER** close parent before all children are done
14. ❌ **NEVER** start coding without a specific work item

## Integration with GitHub Workflow

This workflow integrates with `github-workflow.instructions.md`:
- Follow the issue hierarchy defined there
- Use the API commands specified there
- Respect the parent-child relationships established there
- Apply the same naming conventions and formats

When in doubt, refer to both instruction files to ensure proper work item management throughout the development lifecycle.
