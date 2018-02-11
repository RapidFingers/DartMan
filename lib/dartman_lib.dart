library dartman;

import 'dart:io';

import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/src/dart/scanner/reader.dart';
import 'package:analyzer/src/dart/scanner/scanner.dart';
import 'package:analyzer/src/generated/parser.dart';
import 'package:args/args.dart';
import 'package:analyzer/src/dart/ast/ast.dart';

import 'package:path/path.dart' as path;

part 'src/dartman.dart';
part 'src/code_generator.dart';
part 'src/gdscript_generator.dart';