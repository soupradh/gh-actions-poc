#!/bin/bash
pipeline='basepipeline.yaml'
container='name: cx-app-alpine-java-base-image
platforms:
  - platform:
      name: "java 11"
      version: "11"
      tag_suffix: "java11"
      base_image_tag: "3.18"
  - platform:
      name: "java 11 fips"
      version: "11"
      tag_suffix: "java11-fips"
      base_image_tag: "3.18-fips"
  - platform:
      name: "java 17"
      version: "17"
      tag_suffix: "java17"
      base_image_tag: "3.18"'
name=$(yq ".name" <<<"${container}")
publish_to_legacy_ecr=$(yq ".publish_to_legacy_ecr" <<<"${container}")
platform_count=$(yq ".platforms | length" <<<"${container}")

for i in $(seq 0 $((platform_count - 1))); do
    platform=$(yq ".platforms[$i]" <<<"${container}")
    platform_name=$(yq ".platform.name" <<<"${platform}")
    tag_suffix=$(yq ".platform.tag_suffix" <<<"${platform}")
    echo "Processing ${name}: platform ${platform_name}-${tag_suffix}"

    # Create the workflow job
    build
    normalized_name=$(echo "${name}" | tr '/' '-')
    yq -i ".workflows += {\"build-${normalized_name}\"}" "${pipeline}"
    if [ "${tag_suffix}" == "null" ]; then
      build=".workflows.build-${normalized_name}"
    else
      build=".workflows.build-${normalized_name}-${tag_suffix}"
    fi
    yq -i "${build}.jobs = []" "${pipeline}"
done
