import 'dart:io';

import 'log_untls.dart';

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