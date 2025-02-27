import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_renewfile/log_untls.dart';
import 'package:flutter_renewfile/renew_files.dart';
import 'package:flutter_renewfile/renew_folders.dart';

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

    if (results.rest.contains('files')) {
      renewFiles();
    }else if (results.rest.contains('folders')) {
      renewFolders();
    }else{
      logError('Invalid command. Use "files" or "folders".');
      exit(1);
    }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    logError("❌error = ${e.message}");
    printUsage(argParser);
  }
}


