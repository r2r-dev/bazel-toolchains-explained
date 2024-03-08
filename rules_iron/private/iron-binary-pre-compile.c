/**
 * This program generates a C++ header (.hpp) and source (.cpp) file based on the provided filename
 * and key=value pairs passed as command-line arguments. It creates static constant declarations
 * in the header file for each key=value pair and a main function in the source file that prints
 * these values.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void writeDescription(FILE* file, const char* baseName) {
    fprintf(file, 
        "/**\n"
        " * @file %s\n"
        " * This file was generated automatically.\n"
        " */\n\n", baseName);
}

void writeHeaderFile(const char* baseName, int argc, char* argv[]) {
    char headerFileName[256];
    snprintf(headerFileName, sizeof(headerFileName), "%s.hpp", baseName);

    FILE* headerFile = fopen(headerFileName, "w");
    if (headerFile == NULL) {
        perror("Failed to open header file");
        exit(EXIT_FAILURE);
    }

    // Write file description
    writeDescription(headerFile, headerFileName);

    fprintf(headerFile, 
        "#ifndef %s_hpp\n"
        "#define %s_hpp\n"
        "#include <iostream>\n"
        "#include <string>\n\n", baseName, baseName);

    for (int i = 2; i < argc; ++i) {
        char* key = strtok(argv[i], "=");
        char* value = strtok(NULL, "=");
        if (key == NULL || value == NULL) {
            fprintf(stderr, "Error: Arguments must be in key=value format. Invalid argument: %s\n", argv[i]);
            fclose(headerFile);
            exit(EXIT_FAILURE);
        }
        fprintf(headerFile, "static const std::string %s = \"%s\";\n", key, value);
    }

    fprintf(headerFile, "\n#endif\n");
    fclose(headerFile);
}

void writeSourceFile(const char* baseName, int argc, char* argv[]) {
    char sourceFileName[256];
    snprintf(sourceFileName, sizeof(sourceFileName), "%s.cpp", baseName);

    FILE* sourceFile = fopen(sourceFileName, "w");
    if (sourceFile == NULL) {
        perror("Failed to open source file");
        exit(EXIT_FAILURE);
    }

    // Write file description
    writeDescription(sourceFile, sourceFileName);

    fprintf(sourceFile, 
        "#include \"%s.hpp\"\n"
        "int main() {\n", baseName);

    for (int i = 2; i < argc; ++i) {
        char* key = strtok(argv[i], "=");
        if (key == NULL) {
            fprintf(stderr, "Error: Arguments must be in key=value format. Invalid argument: %s\n", argv[i]);
            fclose(sourceFile);
            exit(EXIT_FAILURE);
        }
        fprintf(sourceFile, "    std::cout << %s << std::endl;\n", key);
        strtok(NULL, "="); // Reset strtok's internal state to NULL for the next argument
    }

    fprintf(sourceFile, "    return 0;\n}\n");
    fclose(sourceFile);
}

int main(int argc, char* argv[]) {
    if (argc < 3) {
        printf("Usage: %s filename key=value...\n", argv[0]);
        return EXIT_FAILURE;
    }

    char* baseName = strtok(argv[1], ".");
    if (baseName == NULL) {
        printf("Invalid filename.\n");
        return EXIT_FAILURE;
    }

    writeHeaderFile(baseName, argc, argv);
    writeSourceFile(baseName, argc, argv);

    return EXIT_SUCCESS;
}

