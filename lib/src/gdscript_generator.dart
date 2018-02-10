part of '../dartman_lib.dart';

/// Code generator for gdscript
class GDScriptGenerator implements CodeGenerator {
  /// Source file path
  final String _filePath;

  /// Output path
  final String _outPath;

  /// Constructor
  GDScriptGenerator(this._filePath, this._outPath);

  /// Generate code
  @override
  void generate() async {
    print(_filePath);
    var file = new File(_filePath);
    print(file.absolute);
    if (!await file.exists())
      throw new GeneratorException("File ${_filePath} not exists");

    var src = await file.readAsString();
    var errorListener = new _ErrorCollector();
    var reader = new CharSequenceReader(src);
    var scanner = new Scanner(null, reader, errorListener);
    var token = scanner.tokenize();
    var parser = new Parser(null, errorListener);
    var unit = parser.parseCompilationUnit(token);

    var visitor = new _ASTVisitor();
    unit.accept(visitor);

    for (var error in errorListener.errors) {
      print(error);
    }
  }
}

/// Visitor of AST
class _ASTVisitor extends GeneralizingAstVisitor {
  @override
  visitClassDeclaration(ClassDeclaration node) {
    for (final mem in node.members) {
      if (mem is ConstructorDeclaration) {
        print(mem.parameters);
      }
    }

    return super.visitClassDeclaration(node);
  }
}

class _ErrorCollector extends AnalysisErrorListener {
  List<AnalysisError> errors;
  _ErrorCollector() : errors = new List<AnalysisError>();
  @override
  onError(error) => errors.add(error);
}