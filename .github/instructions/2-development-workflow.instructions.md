---
applyTo: "**"
---

# Development Workflow Instructions

> **Note**: For GitHub API commands, execution preferences, and issue hierarchy, see [§1-github-api-reference.instructions.md](./1-github-api-reference.instructions.md)

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

For each unchecked acceptance criterion (`- [ ]`), create a Task following the process defined in §1-github-api-reference §"Task Creation from Acceptance Criteria".

Use the sub-issue API to link Tasks to the User Story (see §1-github-api-reference §"Adding Sub-Issues").

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

### 4. Detect and Create Manual Tasks (Tasks Only)

**CRITICAL**: Before validating dependencies, check if the Task requires manual actions from the user. If so, create a manual Task immediately.

#### When to Create Manual Tasks

Analyze the Task description and technical steps. Create a manual Task when:
- ✅ External service configuration (API keys, OAuth, cloud services)
- ✅ Running scripts that require user credentials or permissions
- ✅ Obtaining certificates, tokens, or secrets
- ✅ Manual testing that requires physical devices
- ✅ Deployment or release actions
- ✅ Account setup or third-party registrations
- ✅ Any action that cannot be automated by code changes alone

#### How to Create Manual Tasks

**Step 1: Identify Parent User Story**

Get the parent User Story number from the Task description:
```bash
./gh api repos/EloboAI/crazytrip/issues/<task_number> --jq '.body'
```

Look for `**Parent:** #<number>` at the top.

**Step 2: Create the Manual Task Issue**

Use the GitHub API to create a Task:

```javascript
mcp_githubmcp_issue_write({
  method: "create",
  owner: "EloboAI",
  repo: "crazytrip",
  title: "[Task] [MANUAL] <descriptive_title>",
  body: `**Parent:** #<parent_user_story_number>

**Tipo:** Acción Manual (requiere intervención del usuario)

**Descripción:** <Clear description of what needs to be done>

**Pasos a seguir:**
1. <Step 1 with exact commands or actions>
2. <Step 2 with exact commands or actions>
3. <Step 3 with exact commands or actions>
4. <etc>

**Archivos o recursos necesarios:**
- <File or resource 1>
- <File or resource 2>

**Resultado esperado:**
<What should be the outcome after completing this task>

**Verificación:**
- [ ] <Checklist item 1 to verify completion>
- [ ] <Checklist item 2 to verify completion>

⚠️ **IMPORTANTE:** Este Task debe ser completado por el usuario antes de continuar con el desarrollo.`,
  labels: ["manual-action", "AI-requirement"]
})
```

**Step 3: Link Manual Task to Parent User Story**

Link the manual Task to the parent User Story (NOT to the current Task):

```bash
# Get node IDs
PARENT_NODE_ID=$(./gh api repos/EloboAI/crazytrip/issues/<parent_user_story_number> --jq '.node_id')
MANUAL_TASK_NODE_ID=$(./gh api repos/EloboAI/crazytrip/issues/<new_manual_task_number> --jq '.node_id')

# Add as sub-issue to User Story
./gh api graphql -f query="
mutation {
  addSubIssue(input: {
    issueId: \"$PARENT_NODE_ID\"
    subIssueId: \"$MANUAL_TASK_NODE_ID\"
  }) {
    subIssue {
      id
    }
  }
}"
```

**Step 4: Add to Project and Set Type**

```bash
PROJECT_ID="PVT_kwHOCi99Ic4BHjd7"
TYPE_FIELD_ID="PVTSSF_lAHOCi99Ic4BHjd7zg4RozY"
TYPE_TASK="86b0c338"

# Add to project
ITEM_RESULT=$(./gh api graphql -f query="
mutation {
  addProjectV2ItemById(input: {
    projectId: \"$PROJECT_ID\"
    contentId: \"$MANUAL_TASK_NODE_ID\"
  }) {
    item {
      id
    }
  }
}")

PROJECT_ITEM_ID=$(echo "$ITEM_RESULT" | jq -r '.data.addProjectV2ItemById.item.id')

# Set type to Task
./gh api graphql -f query="
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: \"$PROJECT_ID\"
    itemId: \"$PROJECT_ITEM_ID\"
    fieldId: \"$TYPE_FIELD_ID\"
    value: {singleSelectOptionId: \"$TYPE_TASK\"}
  }) {
    projectV2Item {
      id
    }
  }
}"
```

**Step 5: Assign to User**

```javascript
mcp_githubmcp_issue_write({
  method: "update",
  owner: "EloboAI",
  repo: "crazytrip",
  issue_number: <new_manual_task_number>,
  assignees: ["EloboAI"]  // or the user's GitHub username
})
```

**Step 6: Inform User and STOP**

After creating the manual Task, inform the user and STOP work:

```
⚠️ El Task #<current_task> requiere una acción manual de tu parte.

✅ He creado el Task #<new_manual_task_number>: [MANUAL] <title>

**Este Task está asignado a ti y contiene:**
- Pasos detallados a seguir
- Comandos exactos a ejecutar
- Checklist de verificación

**Debes completar el Task #<new_manual_task_number> antes de que yo pueda continuar con el Task #<current_task>.**

Una vez terminado, por favor:
1. Marca el Task como completado en el proyecto (Status: Done)
2. Avísame para que yo pueda continuar

Enlace directo: https://github.com/EloboAI/crazytrip/issues/<new_manual_task_number>
```

**DO NOT PROCEED with any other validation or implementation steps until the user confirms the manual Task is complete.**

#### Common Manual Task Patterns

**Pattern 1: API Key Configuration**
```
Title: [Task] [MANUAL] Obtener y configurar <Service> API key
Steps:
1. Ir a <Service> Console (<URL>)
2. Crear/seleccionar proyecto
3. Habilitar <API name>
4. Crear API key con restricciones apropiadas
5. Copiar API key

Verification:
- [ ] API key obtenida y guardada de forma segura
- [ ] API key lista para configuración
- [ ] Restricciones aplicadas en console
```

**Pattern 2: Certificate/SHA Fingerprint**
```
Title: [Task] [MANUAL] Obtener SHA-1/SHA-256 fingerprint
Steps:
1. Ejecutar comando: <exact command>
2. Copiar el fingerprint generado
3. Configurar en <external service>

Verification:
- [ ] Fingerprint obtenido
- [ ] Fingerprint configurado en servicio externo
```

**Pattern 3: External Service Setup**
```
Title: [Task] [MANUAL] Configurar cuenta en <Service>
Steps:
1. Crear cuenta en <Service>
2. Crear proyecto
3. Descargar archivos de configuración
4. Confirmar que tienes los archivos

Verification:
- [ ] Cuenta creada
- [ ] Proyecto configurado
- [ ] Archivos de configuración obtenidos
```

#### Rules for Manual Tasks

✅ **ALWAYS** create manual Tasks proactively when detected
✅ **ALWAYS** link manual Tasks to the parent User Story, not the current Task
✅ **ALWAYS** add labels: ["manual-action", "AI-requirement"]
✅ **ALWAYS** include clear step-by-step instructions
✅ **ALWAYS** provide exact commands with placeholder values clearly marked
✅ **ALWAYS** include verification checklist
✅ **ALWAYS** STOP work and wait for user to complete manual Task

❌ **NEVER** proceed with implementation if manual Task is required
❌ **NEVER** create manual Tasks for code implementation
❌ **NEVER** create manual Tasks for automated testing
❌ **NEVER** link manual Tasks to the current Task (always link to User Story)

#### After Manual Task Completion

When user indicates they completed a manual Task:

**Step 1: Verify Status is `Done` in project**

```bash
ISSUE_NUMBER=<manual_task_number>
./gh api graphql -f query='{
  repository(owner: "EloboAI", name: "crazytrip") {
    issue(number: '$ISSUE_NUMBER') {
      projectItems(first: 10) {
        nodes {
          fieldValueByName(name: "Status") {
            ... on ProjectV2ItemFieldSingleSelectValue {
              name
            }
          }
        }
      }
    }
  }
}' --jq '.data.repository.issue.projectItems.nodes[] | select(.fieldValueByName != null) | .fieldValueByName.name'
```

✅ **If Status is `"Done"`:**
- Thank the user
- Continue with the original Task that required the manual action
- Update any configuration files if needed

❌ **If Status is NOT `"Done"`:**
- Inform user that Task is not marked as Done yet
- Ask them to update the Status before continuing

**Step 2: Proceed with Original Task**

Once manual Task is verified complete:
1. Continue with validation workflow (Step 5: Validate Work Item Dependencies)
2. Implement the technical work that depended on the manual action
3. Test that manual configuration is working

### 5. Validate Work Item Dependencies

**CRITICAL**: After handling any manual actions, validate dependencies based on the work item type.

#### For Tasks: Validate Against Parent User Story

##### Step 1: Identify Parent User Story

Check if the Task has a parent reference:
```bash
# Get the task description
./gh api repos/EloboAI/crazytrip/issues/<task_number> --jq '.body'
```

Look for `**Parent:** #<number>` at the top of the description.

##### Step 2: Retrieve Parent User Story Details

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

##### Step 3: Get All Sibling Tasks

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

##### Step 4: Validate Task Alignment

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

##### Step 5: Check Task Dependencies

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

#### For User Stories: Validate Against Feature and Blocking Issues

**CRITICAL**: If the work item is a User Story, validate dependencies at the Feature level.

##### Step 1: Identify Parent Feature

Check if the User Story has a parent reference:
```bash
# Get the User Story description
./gh api repos/EloboAI/crazytrip/issues/<user_story_number> --jq '.body'
```

Look for `**Parent:** #<number>` at the top of the description.

##### Step 2: Check for Blocking Relationships

Query the issue's timeline to find blocking relationships:
```bash
# Get issue details including labels and body
ISSUE_DATA=$(./gh api repos/EloboAI/crazytrip/issues/<user_story_number>)

# Check body for "Blocked by: #<number>" or "Blocks: #<number>"
echo "$ISSUE_DATA" | jq -r '.body' | grep -i "blocked by"
echo "$ISSUE_DATA" | jq -r '.body' | grep -i "blocks"
```

**Blocking relationship patterns in issue body:**
- `**Blocked by:** #<issue_number>` - Cannot start until that issue is closed
- `**Blocks:** #<issue_number>` - Other issues depend on this one

##### Step 3: Validate Blocking Issues Status

If "Blocked by" relationship exists:

```bash
# Get blocking issue state and project status
BLOCKING_ISSUE_NUM=<number_from_blocked_by>
ISSUE_STATE=$(./gh api repos/EloboAI/crazytrip/issues/$BLOCKING_ISSUE_NUM --jq '.state')
PROJECT_STATUS=$(./gh api graphql -f query="{
  repository(owner: \"EloboAI\", name: \"crazytrip\") {
    issue(number: $BLOCKING_ISSUE_NUM) {
      projectItems(first: 10) {
        nodes {
          fieldValueByName(name: \"Status\") {
            ... on ProjectV2ItemFieldSingleSelectValue {
              name
            }
          }
        }
      }
    }
  }
}" --jq '.data.repository.issue.projectItems.nodes[] | select(.fieldValueByName != null) | .fieldValueByName.name' | head -1)

echo "State: $ISSUE_STATE"
echo "Project Status: ${PROJECT_STATUS:-Unassigned}"
```

✅ **Safe to proceed if:**
- Issue state is `closed` **and** project status is `Done`
→ **Continue to Step 4**

❌ **BLOCKED - Cannot proceed if:**
- Issue state is `open`
- Project status is empty or different from `Done`
→ **STOP and inform the developer:**

```
🚫 El User Story #<user_story_number> está BLOQUEADO

**User Story actual:** <current_title>

**Bloqueado por:**
- Issue #<blocking_number>: <blocking_title> [Estado: <open/closed>]

❌ No puedes trabajar en este User Story hasta que se resuelva el issue bloqueante.

**Opciones:**
1. Trabajar en el issue bloqueante #<blocking_number> primero
2. Seleccionar un User Story diferente que no esté bloqueado
3. Revisar si la relación de bloqueo sigue siendo válida

¿Qué quieres hacer?
```

**Wait for developer's decision before proceeding.**

##### Step 4: Get All Sibling User Stories from Feature

If parent Feature exists, get all User Stories:
```javascript
mcp_githubmcp_issue_read({
  method: "get_sub_issues",
  owner: "EloboAI",
  repo: "crazytrip",
  issue_number: <feature_number>
})
```

This returns all User Stories under the Feature with their:
- **Number**: Issue number
- **Title**: User Story title
- **State**: `open` or `closed`
- **State reason**: `completed`, `not_planned`, etc.

##### Step 5: Analyze Logical Dependencies Between User Stories

**Common dependency patterns between User Stories:**

1. **Authentication/Authorization** → Usually prerequisite for all features
2. **Data Model/Schema** → Must exist before CRUD operations
3. **Base Configuration/Settings** → Needed before advanced features
4. **Core Functionality** → Required before enhancements
5. **Backend/API** → Must work before UI implementation

**Dependency Analysis Process:**

1. **Review User Story titles for dependency keywords:**
   - "Configurar", "Crear modelo", "Setup", "Autenticación" → Foundational
   - "Listar", "Mostrar", "Visualizar" → Depends on data model
   - "Editar", "Actualizar", "Eliminar" → Depends on creation/listing
   - "Integrar", "Conectar" → Depends on both systems existing
   - "Persistir", "Guardar" → Depends on data model and UI

2. **Check sibling User Stories states:**
   - List all open User Stories from the Feature
   - Identify which are foundational vs. dependent
   - Check if foundational User Stories are completed

3. **Validate dependency order:**

✅ **Safe to proceed if:**
- No obvious dependencies exist
- All prerequisite User Stories are completed
- User Story is foundational (models, auth, config)
→ **Proceed with User Story**

⚠️ **Potential dependency detected:**
```
⚠️ El User Story #<user_story_number> podría depender de otros User Stories del Feature #<feature_number>

**User Story actual:** <current_us_title>

**User Stories relacionados del mismo Feature:**
- US #<number>: <title> [Estado: <open/closed>]
- US #<number>: <title> [Estado: <open/closed>]
- US #<number>: <title> [Estado: <open/closed>]

**Análisis de dependencias:**
- ❌ US #<number>: <title> parece ser prerequisito (aún abierto)
  Razón: <explain why - e.g., "Crea el modelo de datos necesario">
- ✅ US #<number>: <title> ya está completado
- ⚠️ US #<number>: <title> está abierto pero es independiente

**Recomendación:**
¿Quieres trabajar primero en el US #<prerequisite_number> que es prerequisito?
O si estás seguro de que no hay dependencia, podemos continuar con el US actual.

¿Cómo quieres proceder?
```

**Wait for developer's decision before proceeding.**

##### Step 6: Summary Check Before Proceeding

Before starting work on a User Story, ensure:
- [ ] No "Blocked by" relationships, OR blocking issues are closed/completed
- [ ] No prerequisite User Stories in same Feature are open
- [ ] User Story has Tasks defined (or will be created from acceptance criteria)
- [ ] Iteration is assigned

✅ **All checks passed** → Proceed to iteration validation
❌ **Any check failed** → Wait for developer confirmation or resolution

#### Dependency Validation Rules Summary

❌ **NEVER** work on a Task that depends on incomplete sibling Tasks
❌ **NEVER** work on a User Story that is "Blocked by" an open issue
❌ **NEVER** work on a User Story that depends on incomplete prerequisite User Stories in the same Feature
✅ **ALWAYS** verify alignment with parent (Task → User Story, User Story → Feature)
✅ **ALWAYS** check for explicit blocking relationships in issue body
✅ **ALWAYS** analyze logical dependencies within the same parent
✅ **ALWAYS** ask for clarification if dependencies are unclear
✅ **ALWAYS** suggest working on prerequisite issues first when detected
✅ **ALWAYS** respect developer's decision to override dependency suggestions

### 6. Validate Scope Before Starting

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

### 7. Validate and Assign Iteration

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

### 8. Mark Task as In Progress

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

Once developer confirms:

1. **Cierra el issue en GitHub:**

   ```javascript
   mcp_githubmcp_issue_write({
     method: "update",
     owner: "EloboAI",
     repo: "crazytrip",
     issue_number: <number>,
     state: "closed"
   })
   ```

2. **Actualiza el Status del item en el proyecto a `Done`:**

   ```bash
   PROJECT_ID="PVT_kwHOCi99Ic4BHjd7"
   STATUS_FIELD_ID="PVTSSF_lAHOCi99Ic4BHjd7zg4RobA"
   STATUS_DONE_OPTION="98236657"
   ISSUE_NUMBER=<number>

   PROJECT_ITEM_ID=$(./gh api graphql -f query="{
     repository(owner: \"EloboAI\", name: \"crazytrip\") {
       issue(number: $ISSUE_NUMBER) {
         projectItems(first: 10) {
           nodes {
             id
             project {
               id
             }
           }
         }
       }
     }
   }" --jq '.data.repository.issue.projectItems.nodes[] | select(.project.id == "'$PROJECT_ID'") | .id')

   ./gh api graphql -f query="mutation {
     updateProjectV2ItemFieldValue(input: {
       projectId: \"$PROJECT_ID\"
       itemId: \"$PROJECT_ITEM_ID\"
       fieldId: \"$STATUS_FIELD_ID\"
       value: { singleSelectOptionId: \"$STATUS_DONE_OPTION\" }
     }) {
       projectV2Item { id }
     }
   }"
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
- If ALL sub-issues están cerrados **y** su Status en el proyecto es `Done`
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
1. Cierra el issue del User Story (`state: "closed"`).
2. Actualiza el Status del item en el proyecto a `Done` usando `STATUS_FIELD_ID="PVTSSF_lAHOCi99Ic4BHjd7zg4RobA"` y `STATUS_DONE_OPTION="98236657"` (mismo proceso descrito en §2 paso 2).

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

## Common Scenarios & Decision Tree

### Completion Workflow Decision Tree

```
Developer says: "Ya está lista la tarea #X"
  ↓
Close Task #X (state: "closed" + Status "Done")
    ↓
Check: Does Task have **Parent:** reference?
    ├─ NO → Report: "✅ Task completed (no parent)"
    │        END
    └─ YES → Get Parent issue #P
            ↓
        Get all sub-issues of Parent #P
            ↓
        Are ALL siblings closed?
            ├─ NO → Report: "✅ Task completed. Parent #P has X pending tasks"
            │        Suggest next task
            │        END
            └─ YES → Close Parent #P (state: "closed" + Status "Done")
                    ↓
                Check: Does Parent have grandparent?
                    ├─ NO → Report: "✅ Task and Parent completed"
                    │        END
                    └─ YES → Repeat validation for grandparent
```

### Key Scenario Patterns

**Pattern 1: Misaligned Task** - Task doesn't match User Story criteria
→ **Action**: Compare task description with parent's acceptance criteria. If no match, alert developer and ask for confirmation before proceeding.

**Pattern 2: Out-of-Scope Request** - Developer requests functionality not in work item
→ **Action**: Stop, show current scope, ask if they want to: (1) switch to different work item, (2) create new issue, or (3) continue with current scope only.

**Pattern 3: Incomplete Work** - Developer reports bugs or issues
→ **Action**: Don't close work item. Continue fixing and ask for specific details about what needs correction.

**Pattern 4: Ambiguous Request** - Developer's request unclear or contradictory
→ **Action**: Ask clarification question referencing the work item's defined scope and acceptance criteria.

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
3. ✅ **ALWAYS** detect manual actions needed and create manual Tasks proactively
4. ✅ **ALWAYS** link manual Tasks to parent User Story, not current Task
5. ✅ **ALWAYS** add labels ["manual-action", "AI-requirement"] to manual Tasks
6. ✅ **ALWAYS** STOP work when manual Task is created and wait for user completion
7. ✅ **ALWAYS** validate Task alignment with parent User Story
8. ✅ **ALWAYS** validate User Story against Feature and blocking issues
9. ✅ **ALWAYS** check for "Blocked by" relationships in issue body
10. ✅ **ALWAYS** verify blocking issues are closed before starting
11. ✅ **ALWAYS** check acceptance criteria match before starting Task
12. ✅ **ALWAYS** check sibling Tasks for dependencies before starting
13. ✅ **ALWAYS** check sibling User Stories for dependencies within Feature
14. ✅ **ALWAYS** suggest prerequisite issues when dependencies detected
15. ✅ **ALWAYS** validate iteration assignment before starting work
16. ✅ **ALWAYS** auto-assign to current iteration if none is assigned
17. ✅ **ALWAYS** ask developer before changing existing iteration
18. ✅ **ALWAYS** validate that requests are within scope
19. ✅ **ALWAYS** stop and ask if request is out of scope
20. ✅ **ALWAYS** wait for developer confirmation before closing
21. ✅ **ALWAYS** suggest next logical work item after completing one
22. ✅ **ALWAYS** explain why the suggested work item should be next
23. ✅ **ALWAYS** check parent-child relationships
24. ✅ **ALWAYS** verify all siblings before closing parent
25. ✅ **ALWAYS** set project Status to `Done` when closing an issue
26. ❌ **NEVER** proceed with implementation when manual Task is created
27. ❌ **NEVER** link manual Tasks to the current Task (always User Story)
28. ❌ **NEVER** work on blocked User Stories without resolving blockers
29. ❌ **NEVER** work on misaligned Tasks without developer confirmation
30. ❌ **NEVER** work on dependent Tasks before prerequisites are complete
31. ❌ **NEVER** work on dependent User Stories before prerequisites in same Feature
32. ❌ **NEVER** implement features outside the defined scope
33. ❌ **NEVER** assume additional functionality should be included
34. ❌ **NEVER** close work items prematurely
35. ❌ **NEVER** skip hierarchy validation
36. ❌ **NEVER** skip dependency validation (Tasks or User Stories)
37. ❌ **NEVER** close parent before all children are done
38. ❌ **NEVER** start coding without a specific work item
39. ❌ **NEVER** start work without validating iteration assignment
40. ❌ **NEVER** assume developer wants to continue without asking

