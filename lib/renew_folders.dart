
import 'dart:io';

import 'log_untls.dart';

void renewFolders() {
  // 获取当前目录
  var currentDirectory = Directory.current;

  // 遍历当前目录及其子目录中的所有文件和文件夹
  currentDirectory.list(recursive: true, followLinks: false).forEach((FileSystemEntity entity) {
    // 仅处理文件夹
    if (entity is Directory) {
      var folderName = entity.uri.pathSegments.last;

      // 创建一个新的同名文件夹（加上 _new 后缀）
      var newFolder = Directory('${entity.parent.path}/${folderName}_new');

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

      // 删除原文件夹及其内容
      entity.deleteSync(recursive: true);
      logInfo('删除原文件夹: ${entity.path}');

      // 重命名新文件夹为原文件夹名称（去除 _new 后缀）
      var renamedFolder = Directory('${entity.parent.path}/$folderName');
      newFolder.renameSync(renamedFolder.path);
      logSuccess('重命名新文件夹: ${newFolder.path} -> ${renamedFolder.path}');
    }
  });
}