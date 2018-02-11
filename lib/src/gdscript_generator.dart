part of '../dartman_lib.dart';

/// Extension for gdscript
const String GDSCRIPT_EXTENSION = "gd";

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
    var file = new File(_filePath);
    if (!await file.exists())
      throw new GeneratorException("File ${_filePath} not exists");

    try {
      var dir = new Directory(_outPath);
      if (!await dir.exists()) await dir.create(recursive: true);
    } catch (e) {
      throw new GeneratorException("Can't create out directory");
    }

    var src = await file.readAsString();
    var errorListener = new _ErrorCollector();
    var reader = new CharSequenceReader(src);
    var scanner = new Scanner(null, reader, errorListener);
    var token = scanner.tokenize();
    var parser = new Parser(null, errorListener);
    var unit = parser.parseCompilationUnit(token);

    var visitor = new _ModuleAstVisitor(_outPath);
    unit.accept(visitor);

    for (var error in errorListener.errors) {
      print(error);
    }
  }
}

/// Visitor for module
class _ModuleAstVisitor extends GeneralizingAstVisitor {
  /// Chars in tab
  static const TAB_4 = 4;

  /// Out path
  String _outPath;

  /// Output string builder
  StringBuffer _stringBuilder = new StringBuffer();

  /// Current indent
  int _indent = 0;

  /// Constructor
  _ModuleAstVisitor(this._outPath);

  /// Inc indent
  void incIndent() {
    _indent += 1;
  }

  /// Inc indent
  void decIndent() {
    _indent -= 1;
    if (_indent < 0) _indent = 0;
  }

  /// Write string [data] to buffer
  void writeln(String data) {
    for (var i = 0; i < _indent * TAB_4; i++) {
      _stringBuilder.write(" ");
    }
    _stringBuilder.writeln(data);
  }

  // Write end of line
  void skipLine() {
    writeln("");
  }

  /// Write class
  void writeClass(ClassDeclaration node) {
    writeln("extends Reference");
    skipLine();

    for (final mem in node.members) {
      if (mem is FieldDeclaration) {
        final name = mem.fields.variables.first.name;
        writeln("var ${name}");
      }

      if (mem is ConstructorDeclaration) {
        skipLine();
        writeConstructorDeclaration(mem);
      }

      if (mem is MethodDeclaration) {
        skipLine();
        var params = "";
        var paramlist = mem.parameters.parameters;
        if (paramlist.isNotEmpty) {
          params = paramlist.map((x) => x.identifier).join(",");
        }
        final name = mem.name.name;
        writeln("func ${name}(${params}):");
        incIndent();
        writeNode(mem.body);
        decIndent();
      }
    }
  }

  /// Write constructor declaration
  void writeConstructorDeclaration(ConstructorDeclaration node) {
    var params = <String>[];
    var thisParams = <String>[];
    var paramlist = node.parameters.parameters;
        
    if (paramlist.isNotEmpty) {
      for (var param in paramlist) {
        final name = param.identifier.name;        
        if (param is FieldFormalParameter) {          
          params.add(name);
          thisParams.add(name);
        } else if (param is SimpleFormalParameter) {          
          params.add(name);          
        }
      }
    }    

    var paramString = "";
    if (params.isNotEmpty) {
      paramString = params.join(", ");
    }
    
    var superConstructor = node.childEntities.firstWhere((x) => x is SuperConstructorInvocation, orElse: () => null) as SuperConstructorInvocation;
    if (superConstructor == null) {
      writeln("func _init(${paramString}):");
    } else {
      final txt = superConstructor.argumentList.arguments.join(",");
      writeln("func _init(${paramString}).(${txt}):");
    }
    
    incIndent();
    if (thisParams.isNotEmpty) {
      for (final name in thisParams) {
        writeln("self.${name} = ${name}");
      }
    }

    writeNode(node.body);
    
    decIndent();
  }

  /// Write variable statement
  void writeVariableStatement(VariableDeclarationStatement node) {
    // TODO: fix it
    var txt = node.variables.variables.first;
    writeln("var ${txt}");
  }

  /// Write expression statement
  void writeExpressionStatement(ExpressionStatement node) {
    // TODO: fix it
    var txt = node.childEntities.first;
    writeln("${txt}");
  }

  /// Write function body
  void writeFunctionBody(BlockFunctionBody node) {
    node.childEntities.forEach((f) => writeNode(f));
  }

  /// Write some block
  void writeBlock(Block node) {
    if (node.childEntities.length == 2) {
      writeln("pass");
    } else {
      node.childEntities.forEach((f) => writeNode(f));
    }
  }

  /// Write some node
  void writeNode(SyntacticEntity node) {
    //print(node.runtimeType);
    if (node is ClassDeclaration) {
      writeClass(node);
    } else if (node is VariableDeclarationStatement) {
      writeVariableStatement(node);
    } else if (node is BlockFunctionBody) {
      writeFunctionBody(node);
    } else if (node is Block) {
      writeBlock(node);
    } else if (node is ExpressionStatement) {
      writeExpressionStatement(node);
    }
  }

  /// On class declaration
  @override
  visitClassDeclaration(ClassDeclaration node) async {
    final className = node.name.name;
    final filePath = path.join(_outPath, className) + "." + GDSCRIPT_EXTENSION;
    var file = new File(filePath);

    _stringBuilder.clear();
    writeNode(node);

    await file.writeAsString(_stringBuilder.toString());

    return super.visitClassDeclaration(node);
  }
}

class _ErrorCollector extends AnalysisErrorListener {
  List<AnalysisError> errors;
  _ErrorCollector() : errors = new List<AnalysisError>();
  @override
  onError(error) => errors.add(error);
}
