import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_renewfile/log_untls.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag(
      'version',
      negatable: false,
      help: 'Print the tool version.',
    )
    ..addFlag(
      'renew',
      negatable: false,
      help: '拷贝.dart文件内容，粘贴到新建的.dart文件中',
    );
}

void printUsage(ArgParser argParser) {
  logWarning('Usage: flutter_newfile  <flags> [arguments]');
  logInfo(argParser.usage);
}

void main(List<String> arguments) {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = false;

    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    if (results.wasParsed('version')) {
      logInfo('flutter_newfile version: $version');
      return;
    }
    if (results.wasParsed('verbose')) {
      verbose = true;
    }
    // Act on the arguments provided.
    logInfo('Positional arguments: ${results.rest}');
    if (verbose) {
      logInfo('[VERBOSE] All arguments: ${results.arguments}');
    }

    if (results.rest.contains('renew')) {
      processDirectory();
    }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    logError("❌error = ${e.message}");
    printUsage(argParser);
  }
}

void processDirectory() {
  final directory = Directory.current; // 获取当前目录
  logInfo('Scanning directory: ${directory.path}');

  final files = getDartFiles(directory);
  final totalFiles = files.length;

  if (totalFiles == 0) {
    logError('❌No .dart files found.');
    return;
  }

  logInfo('Total .dart files: $totalFiles');

  for (var i = 0; i < files.length; i++) {
    final file = files[i];
    processDartFile(file, i + 1, totalFiles);
  }

  logSuccess('✅ All files processed successfully!');
}

List<File> getDartFiles(Directory directory) {
  return directory.listSync(recursive: true).whereType<File>().where((file) => file.path.endsWith('.dart')).toList();
}

void processDartFile(File file, int index, int total) {
  final tempFilePath = '${file.path}_copy'; // 临时文件
  final tempFile = File(tempFilePath);

  try {
    final content = file.readAsStringSync();
    tempFile.writeAsStringSync(content);
    file.deleteSync(); // 删除原文件
    tempFile.renameSync(file.path); // 还原原始文件名

    logInfo('[$index/$total] Processed: ${file.path}');
  } catch (e) {
    logError('❌ Error processing file ${file.path}: $e');
  }
}
