#!/usr/bin/env bash

set -e
export PATH=$PATH:/usr/local/bin

export TF_IN_AUTOMATION=1

# Store and return last failure from validate so this can validate every directory passed before exiting
VALIDATE_ERROR=0

main() {
  parse_cmdline_ "$@"
  check_directory_ "$DIR"
  initialize_validate_

  if [ -n "$FILES" ];
    then
      check_config_file_backend "$FILES" "$DIR"
  fi
}

clean_local_terraform_state_folder(){
  echo "Cleaning .terraform folder ..."
  directory=".terraform"

  if [ -d $directory ];
    then
      echo "A .terraform folder has been found. Cleaning it to avoid TF state conflicts"
      find . -name "$directory" -type d -exec rm -rf {} +

    else
      echo 'No .terraform folder was found'
  fi
}

# Check directory - in fails whether the directory passed does not exist
check_directory_(){
  directory="$1"

  if [ -d "$directory" ];
    then
      echo "directory --> $directory validated"
      check_directory=$(ls -ltrah "$directory")

      echo "$check_directory"
    else
      echo "directory --> $directory could not be found in path $(pwd)"
      exit 1
  fi
}

check_config_file_backend(){
  terraform_remote_config_file="$1"
  directory="$2"

  if [[ -e ~/.$directory/$terraform_remote_config_file && ! -L ~/.$directory/$terraform_remote_config_file ]];
    then
        echo "File validated"
        CONFIG_BACKEND+=(~/."$directory"/"$terraform_remote_config_file")
        cat "${CONFIG_BACKEND}"
    else
        echo "file (backend) --> $terraform_remote_config_file does not exist in folder $directory and not a symbolic link"
        exit 1
  fi
}

check_config_file_tfvars(){
  terraform_tfvar_file="$1"
  directory="$2"

  if [[ -e ~/.$directory/$terraform_tfvar_file && ! -L ~/.$directory/terraform_tfvar_file ]];
    then
        echo "File validated"
        CONFIG_TERRAFORM_VAR_FILE+=(~/."$directory"/"$terraform_tfvar_file")
        cat "${CONFIG_TERRAFORM_VAR_FILE}"
    else
        echo "file (tfvars) --> $terraform_tfvar_file  does not exist in folder $directory and not a symbolic link"
  fi
}

initialize_validate_(){
  pushd "$DIR" >/dev/null
  echo "Running validation in directory -->  $DIR"
  echo

  VALIDATE_ERROR=0
  clean_local_terraform_state_folder

  if [ -z "$CONFIG_BACKEND" ];
    then
      terraform init -backend=false || VALIDATE_ERROR=$?
      terraform validate
    else
      # TODO: pending to test properly
      terraform init \
      -backend-config "$CONFIG_BACKEND"
      terraform validate
  fi

  clean_local_terraform_state_folder
  popd >/dev/null

  exit ${VALIDATE_ERROR}
}

parse_cmdline_() {
  declare argv
  argv=$(getopt -o e:a: --long dir:,files: -- "$@") || return
  eval "set -- $argv"

  for argv; do
    case $argv in
      -a | --dir)
        shift
        DIR+=("$6")
        shift
        ;;
      -e | --files)
        shift
        FILES+=("$7")
        shift
        ;;
    esac
  done
}


# global arrays
declare -a DIR
declare -a FILES
declare -a CONFIG_BACKEND
declare -a CONFIG_TERRAFORM_VAR_FILE

[[ ${BASH_SOURCE[0]} != "$0" ]] || main "$@"
