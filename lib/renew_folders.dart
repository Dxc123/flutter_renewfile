import 'dart:io';

import 'package:flutter_renewfile/log_untls.dart';

void renewFolders() {
  final dir = Directory.current; // 获取当前目录
  logInfo('Scanning directory: ${dir.path}');
  printLog('开始处理目录: ${dir.path}', LogLevel.info);

  final entities = dir.listSync(recursive: true); // 递归列出所有文件和文件夹
  for (var entity in entities) {
    if (entity is Directory) {
      final newDirPath = '${entity.path}_new';
      final newDir = Directory(newDirPath);

      try {
        if (!newDir.existsSync()) {
          newDir.createSync(); // 创建新文件夹
          printLog('创建新文件夹: $newDirPath', LogLevel.success);
        }

        moveFiles(entity, newDir); // 移动文件到新文件夹
        removeOldDir(entity); // 删除旧文件夹
        renameNewDir(newDir); // 重命名新文件夹
      } catch (e) {
        printLog('处理目录 ${entity.path} 时出错: $e', LogLevel.error);
      }
    }
  }
}

void moveFiles(Directory oldDir, Directory newDir) {
  final files = oldDir.listSync();
  for (var file in files) {
    if (file is File) {
      try {
        final newFile = File('${newDir.path}/${file.uri.pathSegments.last}');
        file.renameSync(newFile.path); // 移动文件
        printLog('移动文件: ${file.path} 到 ${newFile.path}', LogLevel.success);
      } catch (e) {
        printLog('文件移动失败: ${file.path} -> $e', LogLevel.error);
      }
    }
  }
}

void removeOldDir(Directory oldDir) {
  try {
    final files = oldDir.listSync();
    if (files.isEmpty) {
      oldDir.deleteSync(); // 删除空文件夹
      printLog('删除文件夹: ${oldDir.path}', LogLevel.success);
    }
  } catch (e) {
    printLog('删除文件夹失败: ${oldDir.path} -> $e', LogLevel.error);
  }
}

void renameNewDir(Directory newDir) {
  try {
    final newDirPath = newDir.path.replaceAll('_new', '');
    newDir.renameSync(newDirPath); // 重命名文件夹
    printLog('重命名文件夹: ${newDir.path} -> $newDirPath', LogLevel.success);
  } catch (e) {
    printLog('重命名文件夹失败: ${newDir.path} -> $e', LogLevel.error);
  }
}

void printLog(String message, LogLevel level) {
  final color = _getLogColor(level);
  final levelStr = _getLogLevelString(level);
  print('$color[$levelStr] $message\x1B[0m');
}

String _getLogColor(LogLevel level) {
  switch (level) {
    case LogLevel.info:
      return '\x1B[34m'; // 蓝色
    case LogLevel.success:
      return '\x1B[32m'; // 绿色
    case LogLevel.error:
      return '\x1B[31m'; // 红色
    default:
      return '\x1B[37m'; // 默认颜色
  }
}

String _getLogLevelString(LogLevel level) {
  switch (level) {
    case LogLevel.info:
      return 'INFO';
    case LogLevel.success:
      return 'SUCCESS';
    case LogLevel.error:
      return 'ERROR';
    default:
      return 'UNKNOWN';
  }
}

enum LogLevel { info, success, error }
