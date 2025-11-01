#AÑADE WORKFLOW A TODOS LOS REPOS DE UNA ORG
# Requiere: curl, jq, base64, y un token con permisos de repo (PAT)
ORG="arademo"
TOKEN=""
WORKFLOW_FILE="blank.yml"
WORKFLOW_PATH=".github/workflows/blank.yml"
# Verificar que el archivo existe
if [ ! -f "$WORKFLOW_FILE" ]; then
  echo "ERROR: El archivo $WORKFLOW_FILE no existe."
  exit 1
fi
# Codificar en base64 y eliminar saltos de línea
CONTENT=$(base64 "$WORKFLOW_FILE" | tr -d '\n')
echo "Base64 length: ${#CONTENT}"

# 1. Obtener todos los repositorios de la organización (paginación básica)
PAGE=1
while : ; do
  REPOS=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/orgs/$ORG/repos?per_page=100&page=$PAGE")
  COUNT=$(echo "$REPOS" | jq 'length')
  if [ "$COUNT" -eq 0 ]; then break; fi
  echo "$REPOS" | jq -c '.[]' | while read repo_json; do
    REPO=$(echo "$repo_json" | jq -r '.name')
    DEFAULT_BRANCH=$(echo "$repo_json" | jq -r '.default_branch')
    echo "Agregando workflow a $REPO en rama $DEFAULT_BRANCH..."
    RESPONSE=$(curl -s -X PUT \
      -H "Authorization: token $TOKEN" \
      -H "Accept: application/vnd.github+json" \
      "https://api.github.com/repos/$ORG/$REPO/contents/$WORKFLOW_PATH" \
      -d @- <<EOF
{
  "message": "Add workflow file",
  "content": "$CONTENT",
  "branch": "$DEFAULT_BRANCH"
}
EOF
    )
    echo "$RESPONSE" | jq
  done
  PAGE=$((PAGE+1))
done