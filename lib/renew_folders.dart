import 'dart:io';
import "package:path/path.dart" as p;

void renewFolders() async {
  try {
    final stopwatch = Stopwatch()..start();
    final currentDir = Directory.current;
    printInfo('🚀 Starting directory processing...');

    // Step 1: 递归收集所有目录
    printInfo('📂 Collecting directories...');
    final oldDirs = await _listDirectoriesRecursively(currentDir);
    printSuccess('✅ Found ${oldDirs.length} directories');

    // Step 2: 创建新目录
    printInfo('🛠 Creating new directories...');
    final dirMap = _createDirectoryMap(oldDirs);
    await _createDirectories(dirMap.values);
    printSuccess('✅ Created ${dirMap.length} new directories');

    // Step 3: 移动文件
    printInfo('🚚 Moving files...');
    final files = await _listFilesRecursively(currentDir);
    await _moveFiles(files, dirMap);
    printSuccess('✅ Moved ${files.length} files');

    // Step 4: 删除旧目录
    printInfo('🗑 Deleting old directories...');
    await _deleteDirectories(dirMap.keys);
    printSuccess('✅ Deleted ${dirMap.length} old directories');

    // Step 5: 重命名新目录
    printInfo('🏷 Renaming directories...');
    await _renameDirectories(dirMap.values.toList());
    printSuccess('✅ Renaming completed');

    stopwatch.stop();
    printSuccess('\n🎉 All operations completed in ${stopwatch.elapsed}');
  } catch (e) {
    printError('❌ Critical error: $e');
    exitCode = 1;
  }
}

// 辅助函数
Map<String, String> _createDirectoryMap(List<Directory> directories) {
  final map = <String, String>{};
  for (final dir in directories) {
    final oldPath = dir.path;
    final newPath = p.joinAll(p.split(oldPath).map((part) => '${part}_new').toList());
    map[oldPath] = newPath;
  }
  return map;
}

Future<void> _createDirectories(Iterable<String> paths) async {
  await Future.wait(paths.map((path) async {
    try {
      await Directory(path).create(recursive: true);
      printSuccess('  Created: $path');
    } catch (e) {
      printError('  Failed to create $path: $e');
    }
  }));
}

Future<void> _moveFiles(List<File> files, Map<String, String> dirMap) async {
  await Future.wait(files.map((file) async {
    try {
      final oldPath = file.path;
      final oldDir = p.dirname(oldPath);
      final newDir = dirMap[oldDir]!;
      final newPath = p.join(newDir, p.basename(oldPath));

      await file.rename(newPath);
      printSuccess('  Moved: $oldPath → $newPath');
    } catch (e) {
      printError('  Failed to move ${file.path}: $e');
    }
  }));
}

Future<void> _deleteDirectories(Iterable<String> paths) async {
  await Future.wait(paths.map((path) async {
    try {
      await Directory(path).delete(recursive: true);
      printSuccess('  Deleted: $path');
    } catch (e) {
      printError('  Failed to delete $path: $e');
    }
  }));
}

Future<void> _renameDirectories(List<String> newPaths) async {
  final sortedPaths = List.of(newPaths)..sort((a, b) => p.split(b).length.compareTo(p.split(a).length));

  for (final newPath in sortedPaths) {
    try {
      final targetPath = p.joinAll(p.split(newPath).map((part) => part.replaceAll(RegExp(r'_new$'), '')).toList());
      await Directory(newPath).rename(targetPath);
      printSuccess('  Renamed: $newPath → $targetPath');
    } catch (e) {
      printError('  Failed to rename $newPath: $e');
    }
  }
}

// 文件/目录遍历
Future<List<Directory>> _listDirectoriesRecursively(Directory dir) async {
  final directories = <Directory>[];
  final entities = dir.list(recursive: true);
  await for (final entity in entities) {
    if (entity is Directory) directories.add(entity);
  }
  return directories;
}

Future<List<File>> _listFilesRecursively(Directory dir) async {
  final files = <File>[];
  final entities = dir.list(recursive: true);
  await for (final entity in entities) {
    if (entity is File) files.add(entity);
  }
  return files;
}

// 颜色输出
void printSuccess(String message) => print('\x1B[32m$message\x1B[0m');

void printError(String message) => print('\x1B[31m$message\x1B[0m');

void printInfo(String message) => print('\x1B[34m$message\x1B[0m');
