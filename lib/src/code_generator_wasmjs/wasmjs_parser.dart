import 'package:ffigen/src/code_generator/binding.dart';
import 'package:ffigen/src/code_generator/func.dart';
import 'package:ffigen/src/code_generator/struc.dart';
import 'package:ffigen/src/code_generator_wasmjs/wasmjs_library.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/header_parser/data.dart';
import 'package:ffigen/src/header_parser/parser.dart';

import 'wasmjs_func.dart';
import 'wasmjs_struc.dart';

WasmJsLibrary wasmJsParse(Config c) {
  initParser(c);

  final parsedBindings = parseToBindings();
  final bindings = mapToWasmJs(parsedBindings);

  final library = WasmJsLibrary(
    bindings: bindings,
    name: config.wrapperName,
    description: config.wrapperDocComment,
    header: config.preamble,
    dartBool: config.dartBool,
    sort: config.sort,
    packingOverride: config.structPackingOverride,
  );

  return library;
}

List<Binding> mapToWasmJs(List<Binding> bindings) {
  return bindings.map((b) {
    if (b is Func) return WasmJsFunc(b);
    if (b is Struc) return WasmJsStruc(b);
    return b;
  }).toList();
}
