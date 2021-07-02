import 'package:ffigen/src/code_generator/binding.dart';
import 'package:ffigen/src/code_generator/func.dart';
import 'package:ffigen/src/code_generator/type.dart';
import 'package:ffigen/src/code_generator/writer.dart';

import 'wasmjs_writer.dart';

extension WasmJsType on Type {
  String getWasmJsDartType(Writer w) {
    switch (broadType) {
      case BroadType.NativeType:
      case BroadType.Pointer:
      case BroadType.Compound:
      case BroadType.Enum:
      case BroadType.NativeFunction:
      case BroadType.IncompleteArray:
      case BroadType.ConstantArray:
      case BroadType.Boolean:
      case BroadType.Handle:
      case BroadType.FunctionType:
      case BroadType.Typealias:
      case BroadType.Unimplemented:
        return getDartType(w);
    }
  }

  String getWasmJsLookupDartType(Writer w) {
    switch (broadType) {
      case BroadType.NativeType:
      case BroadType.Pointer:
        return Type.nativeType(SupportedNativeType.Int32).getDartType(w);
      case BroadType.Compound:
      case BroadType.Enum:
      case BroadType.NativeFunction:
      case BroadType.IncompleteArray:
      case BroadType.ConstantArray:
      case BroadType.Boolean:
      case BroadType.Handle:
      case BroadType.FunctionType:
      case BroadType.Typealias:
      case BroadType.Unimplemented:
        return getDartType(w);
    }
  }
}

class WasmJsFunctionType {
  final Type returnType;
  final List<Parameter> parameters;

  WasmJsFunctionType({
    required this.returnType,
    required this.parameters,
  });

  String getDartType(WasmJsWriter w, {bool writeArgumentNames = true}) {
    final sb = StringBuffer();

    // Write return Type.
    sb.write(returnType.getDartType(w));

    // Write Function.
    sb.write(' Function(');
    sb.write(parameters.map<String>((p) {
      return '${p.type.getWasmJsDartType(w)} ${writeArgumentNames ? p.name : ""}';
    }).join(', '));
    sb.write(')');

    return sb.toString();
  }

  void addDependencies(Set<Binding> dependencies) {
    returnType.addDependencies(dependencies);
    for (final p in parameters) {
      p.type.addDependencies(dependencies);
    }
  }
}
