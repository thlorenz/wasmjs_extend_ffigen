import 'package:ffigen/src/code_generator/binding.dart';
import 'package:ffigen/src/code_generator/utils.dart';
import 'package:ffigen/src/code_generator/writer.dart';

class WasmJsWriter extends Writer {
  late String _wasmInstance;
  late String _dartAsync;
  late String _dartConvert;
  late String _dartTyped;
  late String _wasmInterop;

  WasmJsWriter({
    required List<Binding> lookUpBindings,
    required List<Binding> noLookUpBindings,
    required String className,
    required bool dartBool,
    String? classDocComment,
    String? header,
  }) : super(
            lookUpBindings: lookUpBindings,
            noLookUpBindings: noLookUpBindings,
            className: className,
            dartBool: dartBool,
            classDocComment: classDocComment,
            header: header) {
    _wasmInstance = _resolveNameConflict(
      name: '_wasmInstance',
      makeUnique: initialTopLevelUniqueNamer,
      markUsed: [initialTopLevelUniqueNamer],
    );
    _dartAsync = _resolveNameConflict(
      name: 'dartAsync',
      makeUnique: initialTopLevelUniqueNamer,
      markUsed: [initialTopLevelUniqueNamer],
    );
    _dartConvert = _resolveNameConflict(
      name: 'dartConvert',
      makeUnique: initialTopLevelUniqueNamer,
      markUsed: [initialTopLevelUniqueNamer],
    );
    _dartTyped = _resolveNameConflict(
      name: 'dartTyped',
      makeUnique: initialTopLevelUniqueNamer,
      markUsed: [initialTopLevelUniqueNamer],
    );
    _wasmInterop = _resolveNameConflict(
      name: 'wasmInterop',
      makeUnique: initialTopLevelUniqueNamer,
      markUsed: [initialTopLevelUniqueNamer],
    );
  }

  /// Resolved name conflict using [makeUnique] and marks the result as used in
  /// all [markUsed].
  String _resolveNameConflict({
    required String name,
    required UniqueNamer makeUnique,
    List<UniqueNamer> markUsed = const [],
  }) {
    final s = makeUnique.makeUnique(name);
    for (final un in markUsed) {
      un.markUsed(s);
    }
    return s;
  }

  @override
  String generate() {
    final s = StringBuffer();

    // Reset unique namers to initial state.
    resetUniqueNamersNamers();

    // Write file header (if any).
    if (header != null) {
      s.write(header);
      s.write('\n');
    }

    // Write auto generated declaration.
    s.write(makeDoc(
        'AUTO GENERATED FILE, DO NOT EDIT.\n\nGenerated by `package:ffigen`.'));
    s.write('\n');

    // Imports
    s.write("import 'dart:async' as $_dartAsync;\n");
    s.write("import 'dart:convert' as $_dartConvert;\n");
    s.write("import 'dart:typed_data' as $_dartTyped;\n");
    s.write(
        "import 'package:wasm_interop/wasm_interop.dart' as $_wasmInterop;\n");

    if (lookUpBindings.isNotEmpty) {
      if (classDocComment != null) {
        s.write(makeDartDoc(classDocComment!));
      }

      // Write Library wrapper classs.
      s.write('class $className{\n');
      s.write('/// The symbol lookup function.\n');

      // Write lookup function
      s.write('T $lookupFuncIdentifier<T>(String name) {\n');
      s.write('  return $_wasmInstance.functions[name]! as T;\n');
      s.write('}\n');

      // Instance field and constructor
      s.write('final $_wasmInterop.Instance $_wasmInstance;\n');
      s.write('$className(this._wasmInstance);\n');

      /*
      for (final b in lookUpBindings) {
        s.write(b.toBindingString(this).string);
      }
      */

      // Static Initializers
      s.write('\n');
      s.write('static $className? $_wasmInstance;\n');
      s.write('static $className get instance {\n');
      s.write('  assert($_wasmInstance != null,\n');
      s.write(
          '      "need to $className.init() before accessing instance");\n');
      s.write('  return $_wasmInstance!;\n');
      s.write('}\n');
      s.write('\n');
      s.write(
          'static Future<$className> init($_dartTyped.Uint8List moduleData) async {\n');
      s.write(
          '  final $_wasmInterop.Instance instance = await $_wasmInterop.Instance.fromBytesAsync(moduleData);\n');
      s.write('  $_wasmInstance = $className(instance);\n');
      s.write('  return $className.instance;\n');
      s.write('}\n');

      s.write('}\n\n');
    }

    return s.toString();
  }
}