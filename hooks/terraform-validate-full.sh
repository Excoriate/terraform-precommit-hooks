#!/usr/bin/env bash

set -e
export PATH=$PATH:/usr/local/bin

validate_main() {
	parsed_command_line_arguments "$@"

	run_validate
}

# Parse command line arguments
parsed_command_line_arguments() {
  delimiter_flag="="

  for arg in "$@"; do
    echo "argument received --> [$arg]"
  done

  for i in "$@"; do
    case $i in
    -h)
      usage
      exit 0
      ;;
    -b=* | --backend=*)
      raw_input_backend="${i#*=}"
      echo "Raw input backend =====> $raw_input_backend"
      CONFIG_TERRAFORM_REMOTE_BACKEND_FILE_PATH="$raw_input_backend"
      shift # past argument=value
      ;;
    -d=* | --dir=*)
      raw_input_dir="${i#*=}"
      echo "Raw input dir =====> $raw_input_dir"
      DIR="$raw_input_dir"
      shift # past argument=value
      ;;
    *)
      ;;
    *) fatal "Unknown option: '-${i}'" "See '${0} --help' for usage" ;;
    esac
  done

  echo "DIRECTORY                 = ${DIR}"
  echo "BACKEND PATH              = ${CONFIG_TERRAFORM_REMOTE_BACKEND_FILE_PATH}"
}

# Clean up .terraform folder
clean_local_terraform_state_folder(){

  pushd "$DIR" >/dev/null

  echo "directory received: --> $DIR"

  echo "Cleaning .terraform folder in path [$(pwd)]"
  terraform_folder=".terraform"

  if [ -d "$terraform_folder" ]; then
    echo "A .terraform folder has been found. Cleaning it to avoid TF state conflicts"
    echo

    #find . -name "$terraform_folder" -type d -exec rm -rf {} +
    rm -rf "$terraform_folder"
  fi

  popd >/dev/null
}

# Checks whether the local directory passed as argument exists and its valid
check_if_terraform_module_directory_exists() {
  if [[ -d ${DIR} ]]; then
    echo
    echo "Terraform validate (hook) will run on this module --> ${DIR} in path --> $(pwd)"
    echo

  else
    echo
    echo "Error: ${DIR} not found in path $(pwd)"
    echo

    exit 3
  fi
}

# Check whether exists allowed files to be scanned in current directory
check_terraform_files_in_directory() {
  pushd "$DIR" >/dev/null

  local terraform_files_in_path
  terraform_files_in_path=$(find ./ -maxdepth 1 -name "*.tf")

  if [ ${#terraform_files_in_path[@]} -gt 0 ]; then
    echo "Directory contains valid terraform files (.tf)"
    echo
  else
    echo "Error. Cannot identify valid terraform files in directory --> $DIR in path --> $(pwd)"
    echo
    exit 3
  fi

  popd >/dev/null
}

# Describe the usage for this pre-commit hook script
usage() {
  cat - >&2 <<EOF
NAME
    terraform-validate-full.sh - Run a terraform validate command, including a BACKEND configuration

SYNOPSIS
    terraform-validate-full.sh 	[-h|--help]
    terraform-validate-full.sh 	[-d|--dir[=<arg>]]
                      					[-b|--backend[=<arg>]]
                      					[--]

OPTIONS
  -h, --help
          Prints this and exits

  -d, --dir
          The terraform (module) directory

  -b, --backend
          Directory which contains the remote.config file E.g: config/remote.config

EOF
}

# Error handling
fatal() {
  for i; do
    echo -e "${i}" >&2
  done
  exit 1
}

# Validate if a given directory exists
check_config_file_if_exists() {
  pushd "$DIR" >/dev/null
  local local_config_file="$1"

  if [ -f "$local_config_file" ]; then
    echo
    echo "Config file --> $local_config_file validated in path --> $(pwd)"
    echo

  else
    echo
    echo "Error: $local_config_file configuration file not found in path $(pwd)"
    echo

    exit 3
  fi

  popd >/dev/null
}

# Run terraform validate without backend
run_validate_terraform_cmd(){
  pushd "$DIR" >/dev/null
  echo "Running validation in directory -->  $DIR"
  echo

  local error_in_tf_validate
  error_in_tf_validate=0

  if [[ -z ${CONFIG_TERRAFORM_REMOTE_BACKEND_FILE_PATH} ]];
  	then
  		echo "Running without backend"
  		echo

  		terraform init -backend=false || error_in_tf_validate=$?
  	else
  		echo "Terraform Init with backend file configuration in --> $CONFIG_TERRAFORM_REMOTE_BACKEND_FILE_PATH"
      echo

      check_config_file_if_exists "$CONFIG_TERRAFORM_REMOTE_BACKEND_FILE_PATH"

      terraform init \
      	-backend-config "$CONFIG_TERRAFORM_REMOTE_BACKEND_FILE_PATH"
  fi

 	terraform validate || error_in_tf_validate=$?

 	if [[ ${error_in_tf_validate} != 0 ]];
 		then
 			echo "Terraform validate failed in directory --> [$DIR]"
 			echo

 			exit ${error_in_tf_validate}
 	fi

  popd >/dev/null
}

# Wrapper function
run_validate(){
	# validate directory
	check_if_terraform_module_directory_exists

	# clean up .terraform folder
	clean_local_terraform_state_folder

	# validate allowed files and module structure
	check_terraform_files_in_directory

	# Run terraform validate command
	run_validate_terraform_cmd

	# clean up .terraform folder
	clean_local_terraform_state_folder
}

# global arrays
declare -a DIR
declare -a CONFIG_TERRAFORM_REMOTE_BACKEND_FILE_PATH

[[ ${BASH_SOURCE[0]} != "$0" ]] || validate_main "$@"
