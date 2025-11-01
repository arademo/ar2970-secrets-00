#añade workflow a un repo
ORG="arademo"
REPO="ar2970-container-test00"
TOKEN=""
WORKFLOW_FILE="blank.yml"
WORKFLOW_PATH=".github/workflows/blank.yml"
CONTENT=$(base64 "$WORKFLOW_FILE" | tr -d '\n')

curl -X PUT \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$ORG/$REPO/contents/$WORKFLOW_PATH" \
  -d @- <<EOF
{
  "message": "Add workflow file",
  "content": "$CONTENT",
  "branch": "main"
}
EOF