import 'package:ffigen/src/code_generator_wasmjs/wasmjs_library.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/header_parser/data.dart';
import 'package:ffigen/src/header_parser/parser.dart';

WasmJsLibrary wasmJsParse(Config c) {
  initParser(c);

  final bindings = parseToBindings();

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
