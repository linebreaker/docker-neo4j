docker_rm() {
  local cid="$1"
  docker rm --force "${cid}" >/dev/null
}

docker_run() {
  local l_image="$1" l_cname="$2"; shift; shift
  local envs=()
  for env in "$@"; do
    envs+=("--env=${env}")
  done
  local cid="$(docker run --detach "${envs[@]}" --name="${l_cname}" "${l_image}")"
  trap "docker_rm ${cid}" EXIT
}

docker_ip() {
  local l_cname="$1"
  docker inspect --format '{{ .NetworkSettings.IPAddress }}' "${l_cname}"
}

neo4j_wait() {
  local l_ip="$1" end="$((SECONDS+30))"
  if [[ -n "${2:-}" ]]; then
    local auth="--user $2"
  fi

  while true; do
    [[ "200" = "$(curl --silent --write-out '%{http_code}' ${auth:-} --output /dev/null http://${l_ip}:7474)" ]] && break
    [[ "${SECONDS}" -ge "${end}" ]] && exit 1
    sleep 1
  done
}
