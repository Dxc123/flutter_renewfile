import 'dart:io';

import 'package:flutter_renewfile/log_untls.dart';



Future<void> renewFolders() async {
  final directory = Directory.current; // 获取当前目录
  logInfo('Scanning directory: ${directory.path}');

  try {
    // 获取目录下的所有子文件夹
    List<Directory> subDirs = [];
    await for (var entity in directory.list(recursive: false)) {
      if (entity is Directory) {
        subDirs.add(entity);
      }
    }

    // 处理每个文件夹
    for (var dir in subDirs) {
      logInfo('Processing directory: ${dir.path}');
      String newDirPath = '${dir.path}_new';
      Directory newDir = Directory(newDirPath);

      // 如果目标文件夹不存在，创建新文件夹
      if (!await newDir.exists()) {
        await newDir.create(recursive: true);
        logInfo('Created new directory: $newDirPath');
      }

      // 创建对应的子文件夹
      await for (var entity in dir.list(recursive: false)) {
        if (entity is File) {
          // 为每个文件创建对应的新文件夹
          String fileName = entity.uri.pathSegments.last;
          File newFile = File('${newDir.path}/$fileName');
          await entity.copy(newFile.path);
          logInfo('Moved file: ${entity.path} to ${newFile.path}');
        }
      }

      // 删除原文件夹和文件
      await dir.delete(recursive: true);
      logInfo('Deleted original directory: ${dir.path}');
    }

    // 重命名新文件夹
    for (var dir in subDirs) {
      String oldDirPath = dir.path;
      String newDirPath = '${oldDirPath}_new';
      if (Directory(newDirPath).existsSync()) {
        await Directory(newDirPath).rename(oldDirPath);
        logInfo('Renamed new folder: $newDirPath to $oldDirPath');
      }
    }
  } catch (e) {
    logError('Error processing directory: $e');
  }
}
