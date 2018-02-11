part of '../dartman_lib.dart';

/// Parse exception
class ParseException implements Exception {
  /// Message
  String message;

  /// Constructor
  ParseException(this.message);
}

/// Entry point of lib to process args
class Dartman {
  /// Print usage
  void _printUsage(ArgParser parser) {
    print("Usage: pacgen -c=<code file name> -o=<output directory>");
    print("");
    print(parser.usage);
  }

  /// Process arguments
  void process(List<String> args) async {
    var parser = new ArgParser();
    parser.addOption("codeFile", abbr: "c");
    parser.addOption("outDir", abbr: "o");
    parser.addCommand("gdscript");

    try {
      var results = parser.parse(args);
      final codeFile = results["codeFile"];
      final outDir = results["outDir"];
      var hasGdscript = false;
      if (results.command != null) {
        hasGdscript = results.command.name == "gdscript";
      }

      if ((codeFile == null) || (outDir == null))
        throw new ParseException("Wrong usage");

      final generator =
          new CodeGenerator(codeFile, outDir, hasGdscript: hasGdscript);
      await generator.generate();
    } on ParseException catch (e) {
      print(e.message);
    } on GeneratorException catch (e) {
      print(e.message);
    } catch (e) {
      print(e);
      _printUsage(parser);
    }
  }
}
