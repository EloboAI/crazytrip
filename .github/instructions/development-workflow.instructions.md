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

### 4. Validate Task Against Parent User Story

**CRITICAL**: If the work item is a Task, validate it against its parent User Story.

#### Step 1: Identify Parent User Story

Check if the Task has a parent reference:
```bash
# Get the task description
./gh api repos/EloboAI/crazytrip/issues/<task_number> --jq '.body'
```

Look for `**Parent:** #<number>` at the top of the description.

#### Step 2: Retrieve Parent User Story Details

If parent exists, get the User Story:
```javascript
mcp_githubmcp_issue_read({
  method: "get",
  owner: "EloboAI",
  repo: "crazytrip",
  issue_number: <parent_number>
})
```

Extract:
- **Title**: User Story description
- **Criterios de Aceptación**: List of checkboxes

#### Step 3: Get All Sibling Tasks

Retrieve all Tasks from the same User Story:
```javascript
mcp_githubmcp_issue_read({
  method: "get_sub_issues",
  owner: "EloboAI",
  repo: "crazytrip",
  issue_number: <parent_number>
})
```

This returns all Tasks under the User Story with their:
- **Number**: Issue number
- **Title**: Task title
- **State**: `open` or `closed`
- **State reason**: `completed`, `not_planned`, etc.

#### Step 4: Validate Task Alignment

Compare the Task with User Story acceptance criteria:

✅ **Task is VALID if:**
- Task description relates to one of the acceptance criteria
- Task title mentions functionality from acceptance criteria
- Task technical steps implement a specific criterion
→ **Proceed with dependency check (Step 5)**

❌ **Task is MISALIGNED if:**
- Task description doesn't match any acceptance criterion
- Task implements functionality not mentioned in User Story
- Task seems to belong to a different feature
→ **STOP and inform the developer:**

```
⚠️ El Task #<task_number> no parece alineado con su User Story padre #<parent_number>

**User Story:** <parent_title>
**Criterios de Aceptación:**
- [ ] <criterion 1>
- [ ] <criterion 2>
- [ ] <criterion 3>

**Task actual:** <task_title>
**Descripción:** <task_description>

❌ Este Task no corresponde a ninguno de los criterios de aceptación listados.

**Opciones:**
1. ¿Es este el Task correcto para trabajar?
2. ¿Debería trabajar en un Task diferente?
3. ¿Necesitas actualizar el User Story para incluir este criterio?

¿Qué quieres hacer?
```

**Wait for developer's confirmation before proceeding.**

#### Step 5: Check Task Dependencies

**CRITICAL**: Analyze if this Task depends on other Tasks being completed first.

Common dependency patterns:
1. **Setup/Configuration Tasks** must be done before feature Tasks
2. **Provider/Service Tasks** must be done before UI Tasks that use them
3. **Data Model Tasks** must be done before Tasks that manipulate that data
4. **Base Component Tasks** must be done before Tasks that extend them

**Dependency Analysis Process:**

1. **Review Task titles and descriptions** for dependency keywords:
   - "Implementar", "Crear", "Setup" → Usually foundational
   - "Integrar", "Conectar", "Usar" → Usually dependent
   - "Persistir", "Guardar" → Depends on data model
   - "UI", "Pantalla", "Mostrar" → Depends on backend/services

2. **Check sibling Tasks states:**
   - List all open Tasks from the User Story
   - Identify which are foundational vs. dependent
   - Check if foundational Tasks are completed

3. **Validate dependency order:**

✅ **Safe to proceed if:**
- No obvious dependencies exist
- All prerequisite Tasks are completed
- Task is foundational (setup, models, providers)
→ **Proceed with Task**

⚠️ **Potential dependency detected:**
```
⚠️ El Task #<task_number> podría depender de otros Tasks del User Story #<parent_number>

**Task actual:** <current_task_title>

**Tasks relacionados del mismo User Story:**
- Task #<number>: <title> [Estado: <open/closed>]
- Task #<number>: <title> [Estado: <open/closed>]

**Análisis de dependencias:**
- ❌ Task #<number> parece ser prerequisito (aún abierto)
- ✅ Task #<number> ya está completado

**Recomendación:**
¿Quieres trabajar primero en el Task #<prerequisite_number> que es prerequisito?
O si estás seguro de que no hay dependencia, podemos continuar con el Task actual.

¿Cómo quieres proceder?
```

**Wait for developer's decision before proceeding.**

❌ **NEVER** work on a Task that clearly depends on incomplete foundational Tasks
✅ **ALWAYS** verify Task-to-User-Story alignment before starting
✅ **ALWAYS** check sibling Tasks for potential dependencies
✅ **ALWAYS** ask for clarification if the alignment is unclear
✅ **ALWAYS** suggest working on prerequisite Tasks first when detected

### 5. Validate Scope Before Starting

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

### 6. Validate and Assign Iteration

**CRITICAL**: Before starting work on a Task or User Story, validate that it has an iteration assigned.

#### Step 1: Check Current Iteration Assignment

Query the project item to see if it has an iteration assigned:

```bash
# Get the project item ID for the issue
PROJECT_ID="PVT_kwHOCi99Ic4BHjd7"
ISSUE_NODE_ID=$(./gh api repos/EloboAI/crazytrip/issues/<number> --jq '.node_id')

# Find the project item
ITEM_RESULT=$(./gh api graphql -f query="
{
  node(id: \"$PROJECT_ID\") {
    ... on ProjectV2 {
      items(first: 100) {
        nodes {
          id
          content {
            ... on Issue {
              number
            }
          }
          fieldValueByName(name: \"Iteration\") {
            ... on ProjectV2ItemFieldIterationValue {
              title
              startDate
              duration
            }
          }
        }
      }
    }
  }
}")

# Extract iteration info
echo "$ITEM_RESULT" | jq '.data.node.items.nodes[] | select(.content.number == <issue_number>)'
```

#### Step 2: Decision Tree

✅ **If issue HAS current iteration assigned:**
- Proceed with development
- Mark task as in progress

❌ **If issue HAS NO iteration assigned:**
- **AUTOMATICALLY assign to current iteration**
- Use the Iteration field ID and current iteration ID
- Then mark as in progress

❌ **If issue HAS iteration assigned but NOT current:**
- **ASK the developer** if they want to change it to current iteration
- Wait for confirmation before proceeding

#### Step 3: Auto-Assign to Current Iteration (if no iteration)

```bash
# Constants
PROJECT_ID="PVT_kwHOCi99Ic4BHjd7"
ITERATION_FIELD_ID="PVTIF_lAHOCi99Ic4BHjd7zg4RoeM"
ISSUE_NUMBER=<number>

# Get issue node ID
ISSUE_NODE_ID=$(./gh api repos/EloboAI/crazytrip/issues/$ISSUE_NUMBER --jq '.node_id')

# Get project item ID
ITEM_RESULT=$(./gh api graphql -f query="
{
  node(id: \"$PROJECT_ID\") {
    ... on ProjectV2 {
      items(first: 100) {
        nodes {
          id
          content {
            ... on Issue {
              number
            }
          }
        }
      }
    }
  }
}")

PROJECT_ITEM_ID=$(echo "$ITEM_RESULT" | jq -r ".data.node.items.nodes[] | select(.content.number == $ISSUE_NUMBER) | .id")

# Get current iteration ID
CURRENT_ITERATION=$(./gh api graphql -f query="
{
  node(id: \"$PROJECT_ID\") {
    ... on ProjectV2 {
      field(name: \"Iteration\") {
        ... on ProjectV2IterationField {
          configuration {
            iterations {
              id
              title
              startDate
              duration
            }
          }
        }
      }
    }
  }
}" | jq -r '.data.node.field.configuration.iterations[] | select(.title | contains("Iteration")) | .id' | head -1)

# Assign to current iteration
./gh api graphql -f query="
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: \"$PROJECT_ID\"
    itemId: \"$PROJECT_ITEM_ID\"
    fieldId: \"$ITERATION_FIELD_ID\"
    value: {iterationId: \"$CURRENT_ITERATION\"}
  }) {
    projectV2Item {
      id
    }
  }
}"

echo "✅ Issue #$ISSUE_NUMBER asignado a iteración actual"
```

#### Step 4: Ask Developer to Change Iteration (if has different iteration)

```
⚠️ El issue #<number> está asignado a: <iteration_title> (inicia: <start_date>)

La iteración actual es diferente.

¿Quieres cambiarlo a la iteración actual para trabajarlo ahora?
1. Sí, cambiar a iteración actual
2. No, continuar con la iteración asignada

¿Qué prefieres?
```

**Wait for developer's response before proceeding.**

If developer chooses option 1, execute the iteration assignment mutation above with the current iteration ID.

### 7. Mark Task as In Progress

After validating/assigning iteration, update the task state:

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

### 4. Suggest Next Task

**CRITICAL**: After completing a Task, suggest the next logical Task to work on.

#### Step 1: Analyze Remaining Tasks

From the list of sibling Tasks obtained in Step 3:
1. **Filter open Tasks**: Only Tasks with `state: "open"`
2. **Analyze dependencies**: Based on Task titles and descriptions
3. **Prioritize by logic**:
   - Foundational Tasks (setup, models, providers) first
   - Service/logic Tasks second
   - UI/integration Tasks last
   - Independent Tasks can be done anytime

#### Step 2: Suggest Next Task

Present the suggestion to the developer:

```
✅ Task #<completed_task_number> completado

**Tasks restantes del User Story #<parent_number>:**

**Sugerencia de orden de trabajo:**

🔹 **Siguiente recomendado:**
- Task #<number>: <title>
  Razón: <why this should be next - e.g., "Es prerequisito para los demás", "Completa la funcionalidad base", etc.>

📋 **Otros Tasks pendientes:**
- Task #<number>: <title> (Depende de: #<dependency_number>)
- Task #<number>: <title> (Independiente)
- Task #<number>: <title> (UI - hacer después de la lógica)

¿En cuál Task quieres trabajar ahora?
```

#### Step 3: Handle Developer's Choice

**If developer chooses suggested Task:**
- Proceed with validation workflow for that Task (Steps 1-7 from "Starting Work")
- Check iteration assignment
- Start work

**If developer chooses different Task:**
- Ask for confirmation if there are obvious dependencies
- Validate the chosen Task
- Proceed with workflow

**If developer chooses to stop:**
- Confirm completion status
- End session

#### Suggestion Logic Examples

**Example 1: Provider-UI sequence**
```
Completed: Task #180 - Crear ThemeProvider
Suggest: Task #181 - Implementar toggle en UI
Reason: El provider ya está disponible, ahora se puede usar en la UI
```

**Example 2: Model-Service-UI sequence**
```
Completed: Task #200 - Crear modelo de datos User
Suggest: Task #201 - Implementar servicio de autenticación
Reason: El modelo está listo, el servicio lo usa antes de implementar UI
Skip for now: Task #202 - Pantalla de perfil (depende de servicio)
```

**Example 3: Independent Tasks**
```
Completed: Task #150 - Implementar tema oscuro
Suggest: Task #151 - Agregar animaciones (independiente)
OR: Task #152 - Implementar persistencia (independiente)
Reason: Ambos son independientes, puedes elegir cualquiera
```

✅ **ALWAYS** suggest the most logical next Task
✅ **ALWAYS** explain why that Task should be next
✅ **ALWAYS** list all remaining Tasks with their dependencies
✅ **ALWAYS** respect developer's choice if they prefer a different Task
❌ **NEVER** assume the developer wants to continue without asking

### 5. Close Parent if Complete

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

### 6. Repeat for Higher Levels

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

### Scenario 5: Task Misaligned with User Story
```
Developer: "Trabaja en el task #188"
You:
1. Get task description
2. Find parent User Story #156
3. Get acceptance criteria from #156
4. Compare task with criteria
5. If NO MATCH:
   ⚠️ El Task #188 no corresponde a ningún criterio del User Story #156.
   
   **User Story #156:** Activar Dark Mode
   **Criterios:**
   - Toggle entre claro/oscuro
   - Cambio instantáneo
   - Adaptación de elementos UI
   - Contraste adecuado
   
   **Task #188:** Persistencia del tema seleccionado
   
   ❌ Este Task no está en los criterios definidos.
   
   ¿Es el Task correcto o necesitas crear/actualizar el User Story?
```

### Scenario 6: Developer Requests Out-of-Scope Work
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

### Scenario 7: Ambiguous Request Clarification
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
3. ✅ **ALWAYS** validate Task alignment with parent User Story
4. ✅ **ALWAYS** check acceptance criteria match before starting Task
5. ✅ **ALWAYS** validate iteration assignment before starting work
6. ✅ **ALWAYS** auto-assign to current iteration if none is assigned
7. ✅ **ALWAYS** ask developer before changing existing iteration
8. ✅ **ALWAYS** validate that requests are within scope
9. ✅ **ALWAYS** stop and ask if request is out of scope
10. ✅ **ALWAYS** wait for developer confirmation before closing
11. ✅ **ALWAYS** check parent-child relationships
12. ✅ **ALWAYS** verify all siblings before closing parent
13. ✅ **ALWAYS** use `state_reason: "completed"` when closing
14. ❌ **NEVER** work on misaligned Tasks without developer confirmation
15. ❌ **NEVER** implement features outside the defined scope
16. ❌ **NEVER** assume additional functionality should be included
17. ❌ **NEVER** close work items prematurely
18. ❌ **NEVER** skip hierarchy validation
19. ❌ **NEVER** close parent before all children are done
20. ❌ **NEVER** start coding without a specific work item
21. ❌ **NEVER** start work without validating iteration assignment

## Integration with GitHub Workflow

This workflow integrates with `github-workflow.instructions.md`:
- Follow the issue hierarchy defined there
- Use the API commands specified there
- Respect the parent-child relationships established there
- Apply the same naming conventions and formats

When in doubt, refer to both instruction files to ensure proper work item management throughout the development lifecycle.
