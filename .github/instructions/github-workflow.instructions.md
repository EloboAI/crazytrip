---
applyTo: "**"
---

# GitHub Work Items Management Instructions

## Issue Hierarchy and Types

This project follows a strict hierarchical structure for issues:

### Epic → Feature → User Story → Task

1. **Epic**: Highest level, represents major business initiatives (e.g., "Crear aplicación de turismo - Crazytrip")
2. **Feature**: Mid-level, groups related functionality (e.g., "[Feature] Tema Oscuro (Dark Mode)")
3. **User Story**: User-facing functionality with acceptance criteria (e.g., "[User Story] Activar Dark Mode")
4. **Task**: Technical implementation units (e.g., "[Task] Implementar toggle entre modo claro y oscuro")

### Issue Naming Conventions

- **Epic**: `[Epic] Name`
- **Feature**: `[Feature] Name`
- **User Story**: `[User Story] Name`
- **Task**: `[Task] Name`

## Parent-Child Relationships

### Setting Parent Issues

All issues except Epics must have a parent:

```markdown
**Parent:** #<issue_number>
```

Place this at the very top of the issue description.

### Adding Sub-Issues

Use GraphQL API to establish parent-child relationships:

```bash
./gh api graphql -f query='
mutation {
  addSubIssue(input: {
    issueId: "PARENT_NODE_ID"
    subIssueId: "CHILD_NODE_ID"
  }) {
    subIssue {
      id
    }
  }
}'
```

**Important**: Use `./gh` prefix for all GitHub CLI commands in this repository.

## Issue States and State Reasons

### Valid States
- `open`: Issue is active
- `closed`: Issue is completed or won't be done

### State Reasons (when closing)
- `completed`: Successfully finished
- `not_planned`: Won't be implemented
- `duplicate`: Duplicate of another issue

### Closing Issues Properly

```bash
./gh api graphql -f query='
mutation {
  closeIssue(input: {
    issueId: "NODE_ID"
    stateReason: COMPLETED
  }) {
    issue {
      id
      state
    }
  }
}'
```

Or using MCP tools:
```javascript
mcp_githubmcp_issue_write({
  method: "update",
  owner: "EloboAI",
  repo: "crazytrip",
  issue_number: 123,
  state: "closed",
  state_reason: "completed"
})
```

## Iteration Management

### Project Structure

This repository uses GitHub Projects V2 with iteration fields:
- **Project ID**: `PVT_kwHOCi99Ic4BHjd7`
- **Iteration Field ID**: `PVTIF_lAHOCi99Ic4BHjd7zg4RoeM`

### Current Iterations

- **Iteration 1**: Nov 7-21, 2025 (ID: `381c7c80`)
- **Iteration 2**: Nov 21 - Dec 5, 2025 (ID: `54cf5c95`)
- **Iteration 3**: Dec 5-19, 2025 (ID: `d2c335bc`)

### Adding Issues to Project

```bash
./gh api graphql -f query='
mutation {
  addProjectV2ItemById(input: {
    projectId: "PVT_kwHOCi99Ic4BHjd7"
    contentId: "ISSUE_NODE_ID"
  }) {
    item {
      id
    }
  }
}'
```

### Assigning Iterations

```bash
./gh api graphql -f query='
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "PVT_kwHOCi99Ic4BHjd7"
    itemId: "PROJECT_ITEM_ID"
    fieldId: "PVTIF_lAHOCi99Ic4BHjd7zg4RoeM"
    value: {iterationId: "381c7c80"}
  }) {
    projectV2Item {
      id
    }
  }
}'
```

## User Story Format

### Structure

```markdown
**Parent:** #<feature_number>

**Descripción:** Como <role>, quiero <functionality> para <benefit>.

**Criterios de Aceptación:**
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3
- [ ] Criterion 4
```

### Example

```markdown
**Parent:** #38

**Descripción:** Como usuario, quiero activar el modo oscuro para reducir la fatiga visual y ahorrar batería en pantallas OLED.

**Criterios de Aceptación:**
- [x] El usuario puede alternar entre modo claro y oscuro
- [x] El cambio de modo es instantáneo y fluido
- [x] Todos los elementos de la UI se adaptan correctamente
- [x] Los colores mantienen contraste adecuado y legibilidad
```

## Task Creation from Acceptance Criteria

Each acceptance criterion in a User Story should generate ONE Task:

1. **Extract criterion**: Take the text from the checkbox
2. **Create descriptive title**: `[Task] <imperative verb> <what>`
3. **Link to parent**: Add `**Parent:** #<user_story_number>` at top
4. **Add technical details**: Include implementation notes

### Example

Criterion: "El usuario puede alternar entre modo claro y oscuro"

Task:
```markdown
Title: [Task] Implementar toggle entre modo claro y oscuro

Body:
**Parent:** #156

**Descripción:** Implementar la funcionalidad que permita al usuario alternar entre modo claro y oscuro.

**Tareas Técnicas:**
- Crear ThemeProvider con estado de tema
- Implementar método toggleTheme()
- Agregar persistencia con SharedPreferences
```

## Workflow Best Practices

### 1. Creating a Complete Feature

```bash
# 1. Create Feature issue
# 2. Create User Stories with Parent reference
# 3. For each User Story:
#    a. Create Tasks from acceptance criteria
#    b. Link Tasks to User Story via sub-issue API
# 4. Add all to Project
# 5. Assign to current Iteration
```

### 2. Closing Work Items

Close in reverse hierarchy order:
1. Mark all Tasks as `completed`
2. Check all acceptance criteria checkboxes in User Story
3. Close User Story as `completed`
4. When all User Stories done, close Feature
5. When all Features done, close Epic

### 3. Never skip hierarchy levels

❌ Don't link Task directly to Feature
✅ Task → User Story → Feature → Epic

## Labels and Metadata

### Feature-Specific Labels

When creating User Stories and Tasks, apply the parent Feature's label:
- Feature: Dark Mode → Label: `Feature: Dark Mode`
- Description should include Feature number for context

### Example Label Structure

```javascript
{
  name: "Feature: Dark Mode",
  description: "#38 - Tema oscuro",
  color: "5E35B1"
}
```

## Common Patterns

### Creating Multiple Tasks

When a User Story has 4 acceptance criteria, create 4 Tasks:

```bash
# For each criterion:
# 1. Create Task with [Task] prefix
# 2. Add Parent: #<user_story_number>
# 3. Link via sub-issue API
# 4. Mark criterion as checked in User Story
```

### Tracking Progress

- Use checkboxes in User Story descriptions for acceptance criteria
- Check off criteria as corresponding Tasks are completed
- Close User Story only when ALL Tasks are done and criteria checked

## API Reference Quick Guide

### Get Issue Node ID
```bash
./gh api repos/EloboAI/crazytrip/issues/<number> --jq '.node_id'
```

### Get Project Items
```bash
./gh api graphql -f query='
{
  node(id: "PVT_kwHOCi99Ic4BHjd7") {
    ... on ProjectV2 {
      items(first: 100) {
        nodes {
          id
          content {
            ... on Issue {
              number
              title
            }
          }
        }
      }
    }
  }
}'
```

### List Iterations
```bash
./gh api graphql -f query='
{
  user(login: "EloboAI") {
    projectsV2(first: 10) {
      nodes {
        title
        fields(first: 20) {
          nodes {
            ... on ProjectV2IterationField {
              name
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
    }
  }
}'
```

## Critical Rules

1. ✅ **ALWAYS** use `./gh` prefix for GitHub CLI commands
2. ✅ **ALWAYS** set parent reference at top of issue description
3. ✅ **ALWAYS** use sub-issue API for establishing relationships
4. ✅ **ALWAYS** specify `state_reason` when closing issues
5. ✅ **ALWAYS** create Tasks from User Story acceptance criteria
6. ✅ **ALWAYS** add `[Task]` prefix to task titles
7. ✅ **ALWAYS** follow hierarchy: Epic → Feature → User Story → Task
8. ❌ **NEVER** skip hierarchy levels
9. ❌ **NEVER** close parent issues before all children are closed
10. ❌ **NEVER** use plain `gh` command (always `./gh`)
