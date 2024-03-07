#!/bin/sh

# TODO: Detailed description of the script

FILE_BASENAME=$(basename "$1")
FILE_NAME="${FILE_BASENAME%.*}"
shift

write_to_file() {
  echo "${1}" >> "${2}"
}

write_to_header_file() {
  write_to_file "${1}" "${FILE_NAME}.hpp"
}

write_to_source_file() {
  write_to_file "${1}" "${FILE_NAME}.cpp"
}

prepare_header_file() {
  write_to_header_file "#ifndef ${FILE_NAME}_hpp"
  write_to_header_file "#define ${FILE_NAME}_hpp"
  write_to_header_file "#include <iostream>"
  write_to_header_file "#include <string>"
  write_to_header_file ""

  for argument in "$@"; do
      key=${argument%%=*}
      value=${argument#*=}
      write_to_header_file "static const std::string ${key} = \"${value}\";"
  done

  write_to_header_file ""
  write_to_header_file "#endif"
}

prepare_source_file() {
  write_to_source_file "#include \"${FILE_NAME}.hpp\""
  write_to_source_file "int main() {"

  for argument in "$@"; do
      key=${argument%%=*}
      write_to_source_file "std::cout << ${key} << std::endl; ";
  done

  write_to_source_file "return 0;}"
}

prepare_header_file "$@"
prepare_source_file "$@"
