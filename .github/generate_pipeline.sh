function create_container_build() {
  local container=$1
  local pipeline=$2

  local name=$(yq ".name" <<<"${container}")
  local publish_to_legacy_ecr=$(yq ".publish_to_legacy_ecr" <<<"${container}")
  local platform_count=$(yq ".platforms | length" <<<"${container}")

  for i in $(seq 0 $((platform_count - 1))); do
    local platform=$(yq ".platforms[$i]" <<<"${container}")
    local platform_name=$(yq ".platform.name" <<<"${platform}")
    local tag_suffix=$(yq ".platform.tag_suffix" <<<"${platform}")
    echo "Processing ${name}: platform ${platform_name}-${tag_suffix}"

    # Create the workflow job
    local build
    local normalized_name=$(echo "${name}" | tr '/' '-')
    yq -i ".workflows += {\"build-${normalized_name}\"}" "${pipeline}"
    if [ "${tag_suffix}" == "null" ]; then
      build=".workflows.build-${normalized_name}"
    else
      build=".workflows.build-${normalized_name}-${tag_suffix}"
    fi
    yq -i "${build}.jobs = []" "${pipeline}"
}
