# PROMPT PARA AGENTE - Ejecución de Work Items

## Contexto
He generado un plan completo para crear la estructura de work items en GitHub. Ahora necesito que ejecutes cada paso del plan de forma automática.

## Plan a Ejecutar
[AQUÍ SE PEGA EL PLAN GENERADO EN MODO PLAN]

## Instrucciones para el Agente

### Configuración Inicial
```bash
# Variables de entorno
REPO="[OWNER]/[REPO]"
GH="./gh"  # Ubicación del GitHub CLI
COLOR="#5E35B1"  # Deep Purple para todos los labels
```

### Paso 1: Crear Todos los Labels
Genera y ejecuta un script que:
1. Lea el plan y extraiga todos los nombres de features
2. Cree un label para cada feature con formato:
   - Nombre: `Feature: [Nombre]`
   - Color: `#5E35B1`
   - Descripción: `#[número] - [descripción]`

```bash
#!/bin/bash
set -e
GH="./gh"

# Para cada feature en el plan
$GH label create "Feature: [Nombre]" \
  --color "5E35B1" \
  --description "#X - [Descripción]" \
  --repo "[OWNER]/[REPO]"
```

**Ejecutar:** `chmod +x create_labels.sh && ./create_labels.sh`

### Paso 2: Crear Features (Issues Principales)
Genera scripts divididos en partes para crear los features:

**Template por feature:**
```bash
BODY=$(cat <<'EOF'
## Descripción
[Descripción detallada extraída del README]

## Tareas
- [ ] [Tarea técnica 1]
- [ ] [Tarea técnica 2]
- [ ] [Tarea técnica 3]

## User Stories
- #[X] [User Story 1]
- #[Y] [User Story 2]
- #[Z] [User Story 3]

## Dependencias
- Depende de: #[número] ([Nombre])

## Prioridad
[Alta/Media/Baja] - [Razón]
EOF
)

$GH issue create \
  --repo "$REPO" \
  --title "[Feature] [Nombre]" \
  --body "$BODY" \
  --label "Feature: [Nombre]"
```

**Distribución:**
- `create_features_part1.sh` - Features #11-20 (o según el plan)
- `create_features_part2.sh` - Features #21-31
- `create_features_part3.sh` - Features #32-43

**Ejecutar:** `chmod +x create_features_part*.sh && ./create_features_part1.sh & ./create_features_part2.sh & ./create_features_part3.sh`

### Paso 3: Crear User Stories
Genera scripts para crear user stories vinculadas a cada feature:

**Template por user story:**
```bash
BODY=$(cat <<'EOF'
**Parent:** #[número del feature]

**Descripción:** Como [tipo de usuario], quiero [acción] para [beneficio].

**Criterios de aceptación:**
- [ ] [Criterio 1 - específico y verificable]
- [ ] [Criterio 2 - con métricas cuando aplique]
- [ ] [Criterio 3 - incluyendo casos edge]
- [ ] [Criterio 4 - validación de errores]
EOF
)

$GH issue create \
  --repo "$REPO" \
  --title "[User Story] [Acción específica]" \
  --body "$BODY" \
  --label "Feature: [Nombre del feature padre]"
```

**Distribución:**
- `create_user_stories_part1.sh` - Stories para features #11-20
- `create_user_stories_part2.sh` - Stories para features #21-31
- `create_user_stories_part3.sh` - Stories para features #32-43

**Ejecutar:** `chmod +x create_user_stories_part*.sh && ./create_user_stories_part1.sh & ./create_user_stories_part2.sh & ./create_user_stories_part3.sh`

### Paso 4: Establecer Relaciones Sub-Issues (GraphQL)
Genera scripts GraphQL para vincular user stories como sub-issues:

**Template:**
```bash
#!/bin/bash
set -e
GH="./gh"
REPO="[OWNER]/[REPO]"

# Función para obtener node_id
get_node_id() {
    local issue_number=$1
    $GH api graphql -f query="
    query {
        repository(owner: \"[OWNER]\", name: \"[REPO]\") {
            issue(number: $issue_number) {
                id
            }
        }
    }" --jq '.data.repository.issue.id'
}

# Función para añadir sub-issue
add_sub_issue() {
    local parent_node_id=$1
    local sub_issue_node_id=$2
    
    $GH api graphql -f query="
    mutation {
        addSubIssue(input: {
            issueId: \"$parent_node_id\"
            subIssueId: \"$sub_issue_node_id\"
        }) {
            issue {
                number
            }
            subIssue {
                number
            }
        }
    }" 2>&1
}

# Para cada feature y sus user stories
echo "Feature #[X] -> Stories #[A-B]"
PARENT_ID=$(get_node_id [X])
for issue in [A] [B] [C]; do
    SUB_ID=$(get_node_id $issue)
    echo "  Añadiendo #$issue como sub-issue de #[X]..."
    add_sub_issue "$PARENT_ID" "$SUB_ID"
done
```

**Distribución:**
- `add_subissues_graphql_part1.sh` - Features #11-20
- `add_subissues_graphql_part2.sh` - Features #21-31
- `add_subissues_graphql_part3.sh` - Features #32-43

**Ejecutar:** `chmod +x add_subissues_graphql_part*.sh && ./add_subissues_graphql_part1.sh & ./add_subissues_graphql_part2.sh & ./add_subissues_graphql_part3.sh`

## Workflow de Ejecución Completo

### Fase 1: Creación de Labels
```bash
# Generar script
echo "Generando create_labels.sh..."
# [El agente genera el contenido basado en el plan]

# Dar permisos
chmod +x create_labels.sh

# Ejecutar
echo "Creando labels..."
./create_labels.sh

# Verificar
echo "Verificando labels creados..."
gh label list --limit 100
```

### Fase 2: Creación de Features
```bash
# Generar scripts
echo "Generando create_features_part*.sh..."
# [El agente genera los 3 scripts]

# Dar permisos
chmod +x create_features_part1.sh create_features_part2.sh create_features_part3.sh

# Ejecutar en paralelo
echo "Creando features..."
./create_features_part1.sh &
./create_features_part2.sh &
./create_features_part3.sh &
wait

# Verificar
echo "Verificando features creados..."
gh issue list --label "Feature:" --limit 100
```

### Fase 3: Creación de User Stories
```bash
# Generar scripts
echo "Generando create_user_stories_part*.sh..."
# [El agente genera los 3 scripts]

# Dar permisos
chmod +x create_user_stories_part1.sh create_user_stories_part2.sh create_user_stories_part3.sh

# Ejecutar en paralelo
echo "Creando user stories..."
./create_user_stories_part1.sh &
./create_user_stories_part2.sh &
./create_user_stories_part3.sh &
wait

# Verificar
echo "Verificando user stories creados..."
gh issue list --search "[User Story]" --limit 150
```

### Fase 4: Vinculación de Sub-Issues
```bash
# Generar scripts GraphQL
echo "Generando add_subissues_graphql_part*.sh..."
# [El agente genera los 3 scripts]

# Dar permisos
chmod +x add_subissues_graphql_part1.sh add_subissues_graphql_part2.sh add_subissues_graphql_part3.sh

# Ejecutar en paralelo
echo "Vinculando sub-issues..."
./add_subissues_graphql_part1.sh &
./add_subissues_graphql_part2.sh &
./add_subissues_graphql_part3.sh &
wait

# Verificar
echo "Verificando relaciones creadas..."
# [Comando de verificación GraphQL]
```

## Validación Post-Ejecución

### Verificar Labels
```bash
gh label list --limit 100 | grep "Feature:"
# Debe mostrar todos los labels creados
```

### Verificar Features
```bash
gh issue list --label "Feature:" --limit 100 --json number,title,labels
# Debe mostrar todos los features con sus labels
```

### Verificar User Stories
```bash
gh issue list --search "[User Story]" --limit 200 --json number,title,labels,body
# Debe mostrar todas las stories con "Parent: #X" en el body
```

### Verificar Sub-Issues (GraphQL)
```bash
gh api graphql -f query='
query {
  repository(owner: "[OWNER]", name: "[REPO]") {
    issue(number: 11) {
      number
      title
      subIssues(first: 10) {
        totalCount
        nodes {
          number
          title
        }
      }
    }
  }
}'
# Debe mostrar los sub-issues vinculados al feature #11
```

## Manejo de Errores

### Si un script falla:
1. Verificar el error en la salida
2. Identificar el último issue creado exitosamente
3. Modificar el script para empezar desde el siguiente
4. Re-ejecutar el script modificado

### Si hay rate limiting:
1. Esperar 1 minuto
2. Re-ejecutar el script que falló
3. Los scripts deben ser idempotentes (no duplicar issues)

## Reporte Final

Al completar, generar un reporte con:
```markdown
## ✅ Ejecución Completada

### Labels Creados: [X]
- Feature: Geolocalización
- Feature: Identificación IA
- ... (lista completa)

### Features Creados: [Y]
- #11: [Feature] Servicios de Geolocalización
- #12: [Feature] Sistema de Identificación IA
- ... (lista completa)

### User Stories Creados: [Z]
- #44-47: Stories para Feature #11
- #48-51: Stories para Feature #12
- ... (agrupados por feature)

### Relaciones Sub-Issues: [W]
- Feature #11 → 4 sub-issues
- Feature #12 → 4 sub-issues
- ... (lista completa)

### URLs de Verificación:
- Labels: https://github.com/[OWNER]/[REPO]/labels
- Issues: https://github.com/[OWNER]/[REPO]/issues
- Feature #11: https://github.com/[OWNER]/[REPO]/issues/11
```

---

## Instrucciones Finales para el Agente

1. **Lee el plan completo** antes de empezar
2. **Genera todos los scripts** necesarios basándote en el plan
3. **Ejecuta fase por fase** esperando que cada una termine
4. **Verifica cada fase** antes de continuar
5. **Maneja errores** de forma resiliente
6. **Reporta progreso** en cada paso
7. **Genera el reporte final** al completar

**IMPORTANTE:** 
- Usa los datos exactos del plan (números de issues, nombres de features, etc.)
- Mantén la consistencia en nombres y formatos
- Divide operaciones grandes para evitar timeouts
- Ejecuta scripts en paralelo cuando sea seguro
- Verifica el éxito de cada operación

¡Comienza la ejecución!
