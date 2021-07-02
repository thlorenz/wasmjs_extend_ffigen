import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/code_generator/binding_string.dart';
import 'package:ffigen/src/code_generator/utils.dart';
import 'package:ffigen/src/code_generator/writer.dart';

import 'wasmjs_type.dart';

class WasmJsFunc extends LookUpBinding {
  final Func _func;

  late final WasmJsFunctionType functionType;
  bool get exposeSymbolAddress => _func.exposeSymbolAddress;
  bool get exposeFunctionTypedefs => _func.exposeFunctionTypedefs;

  WasmJsFunc(this._func)
      : super(
            usr: _func.usr,
            originalName: _func.originalName,
            name: _func.name,
            dartDoc: _func.dartDoc) {
    functionType = WasmJsFunctionType(
        returnType: _func.functionType.returnType,
        parameters: _func.functionType.parameters);
  }

  @override
  void addDependencies(Set<Binding> dependencies) {
    if (dependencies.contains(this)) return;

    dependencies.add(this);
    functionType.addDependencies(dependencies);
    if (exposeFunctionTypedefs) {
      _func.exposedCFunctionTypealias!.addDependencies(dependencies);
      _func.exposedDartFunctionTypealias!.addDependencies(dependencies);
    }
  }

  @override
  BindingString toBindingString(Writer w) {
    final s = StringBuffer();
    final enclosingFuncName = name;
    final funcVarName = w.wrapperLevelUniqueNamer.makeUnique('_$name');

    if (dartDoc != null) {
      s.write(makeDartDoc(dartDoc!));
    }
    // Resolve name conflicts in function parameter names.
    final paramNamer = UniqueNamer({});
    for (final p in functionType.parameters) {
      p.name = paramNamer.makeUnique(p.name);
    }

    // -----------------
    // Enclosing Function
    // -----------------
    if (w.dartBool &&
        functionType.returnType.getBaseTypealiasType().broadType ==
            BroadType.Boolean) {
      // Use bool return type in enclosing function.
      s.write('bool $enclosingFuncName(\n');
    } else {
      s.write(
          '${functionType.returnType.getWasmJsDartType(w)} $enclosingFuncName(\n');
    }
    // Input params
    for (final p in functionType.parameters) {
      if (w.dartBool &&
          p.type.getBaseTypealiasType().broadType == BroadType.Boolean) {
        // Use bool parameter type in enclosing function.
        s.write('  bool ${p.name},\n');
      } else {
        s.write('  ${p.type.getWasmJsDartType(w)} ${p.name},\n');
      }
    }

    // Function body
    s.write(') {\n');
    s.write('return $funcVarName');

    s.write('(\n');
    for (final p in functionType.parameters) {
      if (w.dartBool &&
          p.type.getBaseTypealiasType().broadType == BroadType.Boolean) {
        // Convert bool parameter to int before calling.
        s.write('    ${p.name}?1:0,\n');
      } else {
        s.write('    ${p.name},\n');
      }
    }
    if (w.dartBool && functionType.returnType.broadType == BroadType.Boolean) {
      // Convert int return type to bool.
      s.write('  )!=0;\n');
    } else {
      s.write('  );\n');
    }
    s.write('}\n');

    // -----------------
    // Enclosed Function
    // -----------------
    s.write(
        'late final ${functionType.returnType.getWasmJsLookupDartType(w)} Function(');
    for (final p in functionType.parameters) {
      s.write('${p.type.getWasmJsLookupDartType(w)},\n');
    }
    s.write(") $funcVarName = _lookup('$enclosingFuncName');\n");

    return BindingString(type: BindingStringType.func, string: s.toString());
  }
}
