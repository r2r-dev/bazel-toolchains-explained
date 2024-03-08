#!/bin/sh

# This script generates a C++ header (.hpp) and source (.cpp) file based on the provided filename
# and key=value pairs passed as command-line arguments. It creates static constant declarations
# in the header file for each key=value pair and a main function in the source file that prints
# these values.

# Check for minimum required arguments
if [ "$#" -lt 1 ]; then
  printf "Usage: %s filename [key=value...]\n" "$0"
  exit 1
fi

# Manually extract the base name without using basename
FILENAME_WITHOUT_PATH="${1##*/}"
FILE_NAME="${FILENAME_WITHOUT_PATH%.*}"
shift  # Remove the first argument so only key=value pairs remain

# Check each remaining argument for the key=value format
for arg in "$@"; do
  # Check if the argument contains an equal sign by looking for the absence of it
  if [ "${arg#*=}" = "$arg" ] || [ "${arg%%=*}" = "$arg" ]; then
    printf "Error: Arguments must be in key=value format. Invalid argument: $arg\n"
    exit 1
  fi

  # Further split the argument into key and value to validate non-emptiness
  key=${arg%%=*}
  value=${arg#*=}

  # Check if key or value is empty
  if [ -z "$key" ] || [ -z "$value" ]; then
    printf "Error: Both key and value must be provided. Invalid argument: $arg\n"
    exit 1
  fi
done

# Function to write content to a specified file type (extension)
write_to_file() {
  printf "%s" "${1}" >> "${FILE_NAME}.${2}"
}

# Function to generate and write a header comment for the files
generate_file_header() {
  header_comment="/**
 * @file ${FILE_NAME}.${1}
 * This file was generated by rules_iron.
 */
"
  write_to_file "$header_comment" "${1}"
}

# Function to check file existence and inform about overwriting
check_and_inform_overwrite() {
  if [ -f "${FILE_NAME}.${1}" ]; then
    printf "Overwriting existing file: %s\n" "${FILE_NAME}.${1}"
    : > "${FILE_NAME}.${1}"
  fi
}

# Prepares and writes the header file content
prepare_header_file() {
  check_and_inform_overwrite "hpp"
  generate_file_header "hpp"
  header_content="#ifndef ${FILE_NAME}_hpp
#define ${FILE_NAME}_hpp
#include <iostream>
#include <string>"

  for argument in "$@"; do
      key=${argument%%=*}
      value=${argument#*=}
      header_content="${header_content}
static const std::string ${key} = \"${value}\";"
  done

  header_content="${header_content}
#endif"
  write_to_file "$header_content" "hpp"
}

# Prepares and writes the source file content
prepare_source_file() {
  check_and_inform_overwrite "cpp"
  generate_file_header "cpp"
  source_content="#include \"${FILE_NAME}.hpp\"
int main() {"

  for argument in "$@"; do
      key=${argument%%=*}
      source_content="${source_content}
    std::cout << ${key} << std::endl;"
  done

  source_content="${source_content}
    return 0;
}"
  write_to_file "$source_content" "cpp"
}

# Generate both header and source files
prepare_header_file "$@"
prepare_source_file "$@"
