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

void renewFiles() {
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


void renewFolders() {
  // 获取当前目录
  var currentDirectory = Directory.current;

  // 遍历当前目录及其子目录中的所有文件和文件夹
  currentDirectory.list(recursive: true, followLinks: false).forEach((FileSystemEntity entity) {
    // 仅处理文件夹
    if (entity is Directory) {
      var folderName = entity.uri.pathSegments.last;

      // 创建一个新的同名文件夹（但加上 _new 后缀）
      var newFolder = Directory('${entity.parent.path}/$folderName\_new');

      // 如果新文件夹不存在，则创建
      if (!newFolder.existsSync()) {
        newFolder.createSync();
        logInfo('创建新文件夹: ${newFolder.path}');
      }

      // 遍历原文件夹中的文件，并将其移动到新文件夹
      entity.listSync().forEach((fileEntity) {
        if (fileEntity is File) {
          var newFilePath = '${newFolder.path}/${fileEntity.uri.pathSegments.last}';
          fileEntity.renameSync(newFilePath);
          logInfo('移动文件: ${fileEntity.path} -> $newFilePath');
        }
      });

      // 删除原文件夹
      entity.deleteSync(recursive: true);
      logInfo('删除原文件夹: ${entity.path}');

      // 重命名新文件夹为原文件夹名称
      var renamedFolder = Directory('${entity.parent.path}/$folderName');
      newFolder.renameSync(renamedFolder.path);
      logSuccess('重命名新文件夹: ${newFolder.path} -> ${renamedFolder.path}');
    }
  });
}


