part of '../dartman_lib.dart';

/// Exception of generator
class GeneratorException implements Exception {
  /// Exception message
  final String message;

  /// Constructor
  const GeneratorException(this.message);
}

/// Generates code
abstract class CodeGenerator {
  /// Create code generator
  factory CodeGenerator(String filePath, String outPath, { bool hasGdscript : false }) {
    if (hasGdscript) {
      return new GDScriptGenerator(filePath, outPath);
    }
    throw const GeneratorException("Unknown format");
  }

  /// Generate code
  void generate();
}