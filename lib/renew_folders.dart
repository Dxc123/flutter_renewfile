import 'dart:async';
import 'dart:io';
import 'package:flutter_renewfile/log_untls.dart';
import 'package:path/path.dart' as p;


void renewFolders() async {
  final directory = Directory.current; // 获取当前目录
  logInfo('Scanning directory: ${directory.path}');
  try {
    if (!directory.existsSync()) {
      logError('Directory does not exist: ${directory.path}');
      return;
    }

    await for (var entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is Directory) {
        // 为每个文件夹创建新文件夹
        String newFolderPath = '${entity.path}_new';
        Directory newFolder = Directory(newFolderPath);
        if (!newFolder.existsSync()) {
          newFolder.createSync();
          logInfo('Created new folder: $newFolderPath');
        }

        // 创建对应子文件夹
        await for (var subEntity in entity.list(recursive: false)) {
          if (subEntity is Directory) {
            String newSubFolderPath = '${subEntity.path}_new';
            Directory newSubFolder = Directory(newSubFolderPath);
            if (!newSubFolder.existsSync()) {
              newSubFolder.createSync();
              logInfo('Created new subfolder: $newSubFolderPath');
            }
          }
        }

        // 将文件移动到新文件夹
        await for (var subEntity in entity.list(recursive: false)) {
          if (subEntity is File) {
            String newFilePath = p.join(newFolder.path, p.basename(subEntity.path));
            subEntity.copy(newFilePath).then((newFile) {
              logInfo('Moved file: ${subEntity.path} -> $newFilePath');
            }).catchError((e) {
              logError('Error moving file: ${subEntity.path} -> $newFilePath, $e');
            });
          }
        }

        // 删除旧文件夹
        await deleteOldFolder(entity);

        // 重命名新文件夹
        if (newFolder.existsSync()) {
          String renamedFolderPath = entity.path;
          Directory(newFolderPath).renameSync(renamedFolderPath);
          logInfo('Renamed folder: $newFolderPath -> $renamedFolderPath');
        }
      }
    }
  } catch (e) {
    logError('An error occurred while processing the directory: $e');
  }
}

Future<void> deleteOldFolder(Directory folder) async {
  try {
    await folder.delete(recursive: true);
    logInfo('Deleted old folder: ${folder.path}');
  } catch (e) {
    logError('Error deleting folder: ${folder.path}, $e');
  }
}
