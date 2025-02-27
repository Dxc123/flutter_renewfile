import 'dart:io';

import 'package:flutter_renewfile/log_untls.dart';

Future<void> renewFolders() async {
  final dir = Directory.current; // 获取当前目录
  logInfo('Scanning directory: ${dir.path}');
  logInfo('开始处理目录: ${dir.path}');
  try {
    // 获取目录下的所有文件和子目录
    List<Future> tasks = [];

    await for (var entity in dir.list(recursive: true)) {
      if (entity is Directory) {
        // 为每个目录创建新的目录（带 "_new" 后缀）
        String newDirPath = '${entity.path}_new';
        Directory newDir = Directory(newDirPath);

        // 如果新目录不存在，则创建它
        if (!await newDir.exists()) {
          tasks.add(newDir.create(recursive: true).then((_) {
            logInfo('Created new folder: $newDirPath');
          }));
        }

        // 递归处理子目录中的文件，并将任务添加到列表
        tasks.add(moveFilesFromOldToNew(entity, newDir));
      }
    }

    // 等待所有任务完成
    await Future.wait(tasks);

    // 删除旧文件夹并重命名新文件夹
    await deleteOldAndRenameNewFolder(dir);

  } catch (e) {
    logInfo('Error processing directory ${dir.path}: $e');
  }
}

Future<void> moveFilesFromOldToNew(Directory oldDir, Directory newDir) async {
  try {
    List<Future> moveTasks = [];

    await for (var entity in oldDir.list()) {
      if (entity is File) {
        String newFilePath = '${newDir.path}/${entity.uri.pathSegments.last}';
        // File newFile = File(newFilePath);

        // 将文件移动操作添加到任务列表
        moveTasks.add(entity.rename(newFilePath).then((_) {
          logSuccess('Moved file: ${entity.path} to $newFilePath');
        }));
      }
    }

    // 等待所有文件移动任务完成
    await Future.wait(moveTasks);
  } catch (e) {
    logError('Error moving files in ${oldDir.path}: $e');
  }
}

Future<void> deleteOldAndRenameNewFolder(Directory oldDir) async {
  try {
    // 删除原目录
    await oldDir.delete(recursive: true);
    logSuccess('Deleted old folder: ${oldDir.path}');

    // 重命名新文件夹
    String newDirPath = '${oldDir.path}_new';
    Directory newDir = Directory(newDirPath);
    String finalDirPath = oldDir.path;

    // 确保新目录存在并进行重命名
    if (await newDir.exists()) {
      await newDir.rename(finalDirPath);
      logSuccess('Renamed folder to: $finalDirPath');
    } else {
      logError('Error: New folder does not exist.');
    }
  } catch (e) {
    logError('Error deleting or renaming folder: $e');
  }
}
