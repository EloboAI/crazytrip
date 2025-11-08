# PROMPT PARA MODO PLAN - Generación de Work Items desde README

## Contexto
Necesito generar una estructura completa de work items (issues) en GitHub basándome en el roadmap y features descritos en el README.md del proyecto.

## Estructura del Proyecto
- **Repositorio:** [OWNER]/[REPO]
- **README.md:** [Ubicación del archivo con el roadmap]
- **GitHub CLI:** Disponible en ./gh

## Objetivos del Plan

### 1. Análisis del README
Analiza el README.md y extrae:
- Todas las features principales del roadmap
- Prioridad de cada feature (Alta/Media/Baja)
- Dependencias entre features
- Tecnologías y herramientas mencionadas

### 2. Diseño de Labels
Para cada feature identificada, crea:
- **Nombre del label:** `Feature: [Nombre Corto]`
- **Color:** `#5E35B1` (Deep Purple - consistente para todos)
- **Descripción:** `#[número] - [Descripción breve]`

### 3. Estructura de Features
Para cada feature, genera:
- **Título:** `[Feature] [Nombre Descriptivo]`
- **Descripción completa** que incluya:
  ```markdown
  ## Descripción
  [Descripción detallada de la feature]
  
  ## Tareas
  - [ ] [Tarea técnica 1]
  - [ ] [Tarea técnica 2]
  - [ ] [Tarea técnica 3]
  
  ## User Stories
  - #[número] [Referencia a user story 1]
  - #[número] [Referencia a user story 2]
  
  ## Dependencias
  - Depende de: #[número] ([Nombre feature])
  
  ## Prioridad
  [Alta/Media/Baja] - [Razón]
  ```
- **Label:** Asignar el label correspondiente

### 4. User Stories por Feature
Para cada feature, genera 3-5 user stories con:
- **Título:** `[User Story] [Acción específica del usuario]`
- **Formato:**
  ```markdown
  **Parent:** #[número del feature]
  
  **Descripción:** Como [tipo de usuario], quiero [acción] para [beneficio].
  
  **Criterios de aceptación:**
  - [ ] [Criterio verificable 1]
  - [ ] [Criterio verificable 2]
  - [ ] [Criterio verificable 3]
  - [ ] [Criterio verificable 4]
  ```
- **Label:** El mismo que el feature padre

### 5. Relaciones Sub-Issues
Usando GraphQL API, establecer:
- Cada user story como sub-issue de su feature padre
- Usar la mutación `addSubIssue` con node_ids

## Plan de Ejecución

### Fase 1: Preparación
1. Leer y analizar README.md completo
2. Identificar todas las features (estimar 30-50 features)
3. Agrupar features por categorías lógicas
4. Definir dependencias entre features

### Fase 2: Creación de Labels
1. Generar script bash para crear todos los labels
2. Ejecutar: `gh label create "Feature: [Nombre]" --color 5E35B1 --description "[Desc]"`
3. Crear labels para features pre-existentes si aplica

### Fase 3: Creación de Features
1. Generar script bash dividido en partes (10-15 features por script)
2. Crear cada feature con su descripción completa
3. Formato: `gh issue create --title "[Feature] X" --body "$BODY" --label "Feature: X"`

### Fase 4: Creación de User Stories
1. Dividir en múltiples scripts (40-50 stories por script)
2. Crear cada user story con referencia al feature padre
3. Asignar el mismo label que el feature
4. Incluir "**Parent:** #X" en el body

### Fase 5: Vinculación de Sub-Issues
1. Crear scripts GraphQL para establecer relaciones padre-hijo
2. Dividir en partes (40-50 relaciones por script)
3. Usar:
   ```bash
   # Obtener node_id
   gh api graphql -f query='{ repository(owner: "X", name: "Y") { issue(number: N) { id } } }'
   
   # Crear sub-issue
   gh api graphql -f query='mutation { addSubIssue(input: { issueId: "PARENT_ID", subIssueId: "SUB_ID" }) { issue { number } } }'
   ```

## Entregables del Plan

### Scripts a generar:
1. `create_labels.sh` - Crea todos los labels
2. `create_features_part[1-N].sh` - Crea features (dividido)
3. `create_user_stories_part[1-N].sh` - Crea user stories (dividido)
4. `add_subissues_graphql_part[1-N].sh` - Vincula sub-issues (dividido)

### Estructura de archivos:
```
scripts/
├── create_labels.sh
├── create_features_part1.sh
├── create_features_part2.sh
├── create_user_stories_part1.sh
├── create_user_stories_part2.sh
├── create_user_stories_part3.sh
├── add_subissues_graphql_part1.sh
├── add_subissues_graphql_part2.sh
└── add_subissues_graphql_part3.sh
```

## Consideraciones Técnicas

### Límites y Paginación:
- Dividir operaciones grandes en lotes de 40-50 items
- Cada script debe ser independiente y reanudable
- Usar `set -e` para detener en errores

### Formato de User Stories:
- Siempre en español (o idioma del proyecto)
- Seguir formato: "Como [rol], quiero [acción] para [beneficio]"
- 2-4 criterios de aceptación por story
- Criterios deben ser verificables y específicos

### Naming Conventions:
- Features: `[Feature] Nombre Descriptivo`
- User Stories: `[User Story] Acción Específica`
- Labels: `Feature: Nombre Corto`

## Validación del Plan

Antes de ejecutar, verificar:
- [ ] Todos los features tienen entre 3-5 user stories
- [ ] Todos los labels tienen el mismo color (#5E35B1)
- [ ] Las dependencias entre features están correctamente identificadas
- [ ] Los scripts están divididos apropiadamente para evitar timeouts
- [ ] Cada user story tiene "**Parent:** #X" en su descripción
- [ ] Los scripts GraphQL obtienen node_ids correctamente

## Output Esperado

Generar un plan detallado que incluya:
1. **Lista completa de features** (con números estimados)
2. **Distribución de user stories** por feature
3. **Nombres de todos los labels** a crear
4. **Estructura de scripts** con nombres y propósito
5. **Orden de ejecución** recomendado
6. **Comandos de verificación** para confirmar éxito

## Ejemplo de Salida del Plan

```markdown
PLAN DE EJECUCIÓN - Generación de Work Items

FEATURES IDENTIFICADAS: 45
- #11-20: Core Features (Geolocalización, IA, CrazyDex, etc.)
- #21-31: Social & Community Features
- #32-43: Advanced Features

USER STORIES TOTALES: 136
- Promedio: 3 stories por feature
- Rango: 3-5 stories por feature

LABELS A CREAR: 45
- Color: #5E35B1 (Deep Purple)
- Formato: "Feature: [Nombre]"

SCRIPTS A GENERAR:
1. create_labels.sh (45 labels)
2. create_features_part1.sh (Features #11-20)
3. create_features_part2.sh (Features #21-31)
4. create_features_part3.sh (Features #32-43)
5. create_user_stories_part1.sh (Stories #44-86)
6. create_user_stories_part2.sh (Stories #87-131)
7. create_user_stories_part3.sh (Stories #132-179)
8. add_subissues_graphql_part1.sh (Features #11-20)
9. add_subissues_graphql_part2.sh (Features #21-31)
10. add_subissues_graphql_part3.sh (Features #32-43)

ORDEN DE EJECUCIÓN:
1. ./create_labels.sh
2. ./create_features_part*.sh (en paralelo)
3. ./create_user_stories_part*.sh (en paralelo)
4. ./add_subissues_graphql_part*.sh (en paralelo)

VERIFICACIÓN:
- gh issue list --limit 200 --json number,title,labels
- gh api graphql -f query='{ ... }' (verificar sub-issues)
```

---

**IMPORTANTE:** Este es el prompt para MODO PLAN. Una vez generado el plan, este se pasará al agente para ejecutar cada paso automáticamente.
