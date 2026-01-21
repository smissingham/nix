#!/bin/sh

get_compose_files() {
  fd -t f ".*compose.*\.yaml"
}

get_compose_services() {
  fd -t f ".*compose.*\.yaml" | sed 's/[.\-]//g; s/compose//g; s/yaml//g'
}

create_shared_networks() {
  SHARED_NETWORKS="databases"
  for network in $SHARED_NETWORKS; do
    "$DOCKER_ALIAS" network create "$network" 2>/dev/null || true
  done
}

create_app_directories() {
  for service_name in $(get_compose_services); do
    mkdir -p "$APPDATA_PATH/$service_name"
    mkdir -p "$APPCONF_PATH/$service_name"
  done

  ln -s "$APPDATA_PATH" . 2>/dev/null || true
}

list_containers() {
  echo ""
  podman ps -a --format json | jq -r '.[] | 
    "\(.Names // [] | join(", "))\t\(.Labels["com.docker.compose.project"] // "")\t\(.Networks // [] | join(", "))\t\(.Status)"' |
    column -t -s $'\t' -N "NAMES,SERVICE,NETWORKS,STATUS"
  echo ""
}

init_containers() {
  docker ps --format '{{.Names}}' | grep -q '^ollama$' && [ -n "${OLLAMA_MODELS}" ] && {
    for model in $OLLAMA_MODELS; do
      docker exec ollama ollama list | grep -q "^${model}" || docker exec ollama ollama pull "$model"
    done
  }

  docker ps --format '{{.Names}}' | grep -q '^librechat-mongodb$' &&
    [ -n "${HOSTING_ADMIN_EMAIL}" ] && [ -n "${HOSTING_ADMIN_USERNAME}" ] && [ -n "${HOSTING_ADMIN_PASSWORD}" ] && {
    docker exec librechat-mongodb mongosh LibreChat --quiet --eval "db.users.findOne({email: '${HOSTING_ADMIN_EMAIL}'})" 2>/dev/null | grep -q "${HOSTING_ADMIN_EMAIL}" || {
      echo "Y" | docker exec -i librechat-api npm run create-user \
        "${HOSTING_ADMIN_EMAIL}" \
        "${HOSTING_ADMIN_USERNAME}" \
        "${HOSTING_ADMIN_USERNAME}" \
        "${HOSTING_ADMIN_PASSWORD}" \
        --role=ADMIN >/dev/null 2>&1
    }
  }
}

up() {
  create_shared_networks
  create_app_directories

  for compose_file in $(get_compose_files); do
    "$COMPOSE_ALIAS" -f "$compose_file" up -d 2>/dev/null || true
  done

  list_containers
  init_containers
}

rl() {
  stack_name="$1"
  [ -z "$stack_name" ] && echo "Usage: rl <stack_name>" && return 1

  compose_file="compose.${stack_name}.yaml"
  [ ! -f "$compose_file" ] && echo "Stack $stack_name not found" && return 1

  "$COMPOSE_ALIAS" -f "$compose_file" down 2>/dev/null
  "$COMPOSE_ALIAS" -f "$compose_file" up -d 2>/dev/null
}

if [ -f .setenv.sh ]; then
  . ./.setenv.sh
fi

"$@"
