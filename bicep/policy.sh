#! /usr/bin/env bash

readonly SCRIPT_PATH=$(readlink -m $(dirname $0))

error_log() {
  printf "\e[91mError: $1\e[97m\n" >&2
  exit 1
}

usage() {
    sect() {
        printf "\e[97m${1@U}\n\e[0m"
    }
    line() {
        printf "\t$1\n"
    }
    # Indentation doesn't do anything. just meant for readability.
    sect "overview:"
        line ""
        line "This script provisions the policy definitions, the initiative definitions and the policy/initiative assignments."
        line "Data is read in from json files for the definitions and assignments to be deployed via bicep."
        line "The script does assume the following folder structure:"
        line "."
        line "├── bicep"
        line "│   ├── main.bicep"
        line "│   ├── ..."
        line "│   └── \e[95mpolicy.sh (<= THIS IS THE SCRIPT)\e[0m"
        line "├── policy-assignments"
        line "│   ├── assignment1.json"
        line "│   ├── assignment2.json"
        line "│   ├── assignment3.json"
        line "│   └── ..."
        line "├── policy-definitions"
        line "│   ├── policy1.json"
        line "│   ├── policy2.json"
        line "│   ├── policy3.json"
        line "│   └── ..."
        line "└── policy-initiatives"
        line "    ├── init1.json"
        line "    ├── init2.json"
        line "    ├── init3.json"
        line "    └── ..."
        line ""
    sect "usage:"
        line "\e[31m"
        line "policy.sh [OPTIONS]"
        line "\e[0m"
    sect "examples:"
        line "\e[32m"
        line "policy.sh --help" 
        line "policy.sh -c" 
        line "policy.sh -d" 
        line "policy.sh --get --policy --id <policy definition id>" 
        line "policy.sh --get -ai <assignment id>" 
        line "policy.sh -gsi <initiative definition id>" 
        line "\e[0m"
    sect "options:"
        line "\e[34m"
        line "-h,--help : (Switch) Outputs help menu."
        line "-g,--get : (Switch) Tells the script to operate in get mode to output definitions or assignments in JSON format. Must be used with either --policy/-p, --policy-set/-s"
        line "    or --assignment/a. Furthermore if any of the three options (-p, -s or -a) are used then --id/-i must also be provided."
        line "-p,--policy : (Switch) Specifies that --get/-g should obtain a policy definition JSON object. If used, the id of the policy definition is passed in via the --id/-i parameter."
        line "-s,--policy-set : (Switch) Specifies that --get/-g should obtain an initiative definition JSON object. If used, the id of the initiative definition is passed"
        line "    in via the --id/-i parameter."
        line "-a,--assignment : (Switch) Specifies that --get/-g should obtain an assignment JSON object. If used, the id of the assignment if passed in via the --id/-i parameter."
        line "-i,--id : (Value) Required if -g/--get flag is provided. If --policy/-p is used, then --id/-i must be the value of a policy id. If --policy-set/-s is used"
        line "    then --id/-i must be the value of an initiative id. Finally if --assignment/-a is used, then --id/-i must be the value of a policy / initiative assignment."
        line "-c,--create : (Switch) Creates the deployment stack and deploys policy / initiative definitions and corresponding assignments."
        line "-d,--delete : (Switch) Deletes the deployment stack and deletes all policy / initiative definitions and corresponding assignments."
        line "\e[0m"
    unset sect
    unset line
}

parse_args() {
  args=""
  for x in "$@"; do
    args="$args${x}\""
  done
  args=${args//=/\"}
  args=${args%%\"}
  IFS=$'"'
  set -- $args
  while [[ "${1}" != '' ]]; do
    case $1 in 
      --create|-c) create_flag=true; shift;;
      --delete|-d) delete_flag=true; shift;;
      --get|-g) get_flag=true; shift;;
      --policy|-p) policy_flag=true; shift;;
      --policy-set|-s) policy_set_flag=true; shift;;
      --assignment|-a) assignment_flag=true; shift;;
      --id|-i) id=$2; shift; shift;;
      --help|-h) help_flag=true; shift;;
      -[a-zA-Z]*)
        opstring=${1##-}
        for (( i = 0; i < ${#opstring}; i++ )); do
          if (( $i == ${#opstring} - 1 )); then
            case "-${opstring:i:1}" in 
              -p) policy_flag=true;;
              -s) policy_set_flag=true;;
              -a) assignment_flag=true;;
              -c) create_flag=true;;
              -d) delete_flag=true;;
              -g) get_flag=true;;
              -i) id=$2; shift;;
              -h) help_flag=true;;
            esac
            shift;
            break
          fi
          case "-${opstring:i:1}" in 
            -p) policy_flag=true; continue;;
            -s) policy_set_flag=true; continue;;
            -a) assignment_flag=true; continue;;
            -g) get_flag=true; continue;;
            -c) create_flag=true; continue;;
            -d) delete_flag=true; continue;;
            -h) help_flag=true; continue;;
          esac
        done
      ;;
      -*) error_log "argument '$1' unrecognized"
    esac
  done
  IFS=$'\t\n '
}

general_error_checking() {
  if [[ "${create_flag}" == "true" ]] && [[ "${delete_flag}" == "true" ]]; then
    error_log "cannot use --create/-c and --delete/-d flag together."
    exit 1
  fi
}

parse_help_mode() {
  if [[ -z "$@" ]] || [[ "${help_flag}" == "true" ]]; then
    echo "entered parse help mode"
    usage
    exit 0
  fi
}

parse_get_mode() {
  if [[ "${get_flag}" == "true" ]]; then

    if [[ "${policy_flag}" == "true" ]] && [[ "${policy_set_flag}" == "true" ]]; then
      error_log "Cannot specify --policy/-p and --policy-set/-s flags together."
      exit 1
    fi

    if [[ "${policy_flag}" == "true" ]] && [[ "${assignment_flag}" == "true" ]]; then
      error_log "Cannot specify --policy/-p and --assignment/-a flags together."
      exit 1
    fi

    if [[ "${policy_set_flag}" == "true" ]] && [[ "${assignment_flag}" == "true" ]]; then
      error_log "Cannot specify --policy-set/-s and --assignment/-a flags together."
      exit 1
    fi

    if [[ -z "${policy_flag}" ]] && [[ -z "${policy_set_flag}" ]] && [[ -z "${assignment_flag}" ]]; then
      error_log "must specify --policy/-p or --policy-set/-s or --assignment/-a to specify the type of object to be returned with --get/-g flag"
      exit 1
    fi

    if [[ -z "${id}" ]]; then
      error_log "must specify value to --id/-i for getting definitions or assignments."
      exit 1
    fi

    az rest --method "get" --uri "https://management.azure.com/${id}\?api-version=2023-04-01"
    exit 0

  fi
}

parse_create_mode() {
  if ! type -p jq > /dev/null; then
    error_log "jq is required for parsing the json files. sorry."
  fi
  if [[ "${create_flag}" == "true" ]]; then
    role_dictionary_json=$(az role definition list --query '[].{name: name, id: id}' | jq '. | map(.key = .name) | map(.value = .id) | map(del(.id)) | map(del(.name)) | from_entries')
    policy_definitions_array_json=$(jq --slurp --compact-output '.' ${SCRIPT_PATH}/../policy-definitions/*.json)
    policy_initiatives_array_json=$(jq --slurp --compact-output '.' ${SCRIPT_PATH}/../policy-initiatives/*.json)
    policy_assignments_array_json=$(jq --slurp --compact-output '.' ${SCRIPT_PATH}/../policy-assignments/*.json)
    az bicep build-params --file "${SCRIPT_PATH}/main.bicepparam" --outfile "${SCRIPT_PATH}/main.json"
    output=$(jq --null-input \
      --argfile main "${SCRIPT_PATH}/main.json" \
      --argfile role_dictionary <(printf "%s" $role_dictionary_json) \
      --argfile policy_definitions <(printf "%s" $policy_definitions_array_json) \
      --argfile policy_initiatives <(printf "%s" $policy_initiatives_array_json) \
      --argfile policy_assignments <(printf "%s" $policy_assignments_array_json) \
      '$main | .parameters.p_role_dictionary.value = $role_dictionary | .parameters.p_policies.value = $policy_definitions | .parameters.p_initiatives.value = $policy_initiatives | .parameters.p_policy_assignments.value = $policy_assignments'
    )
    echo $output | jq > "${SCRIPT_PATH}/main.json"
    az stack mg create --management-group-id "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" --name "test" --location "australiaeast" --template-file "${SCRIPT_PATH}/main.bicep" --parameters "${SCRIPT_PATH}/main.json" --action-on-unmanage "deleteAll" --deny-settings-mode "none" --yes
    rm -rf "${SCRIPT_PATH}/main.json"
    exit 0
  fi
}

parse_delete_mode() {
  if [[ "${delete_flag}" == "true" ]]; then
    az stack mg delete --management-group-id "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" --name "test" --action-on-unmanage "deleteAll" --yes
    exit 0
  fi
}


########## BEGIN SCRIPT ##########
parse_args "$@"
general_error_checking
parse_help_mode "$@"
parse_get_mode
parse_create_mode
parse_delete_mode
