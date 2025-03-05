 ## dart cli 工具:

####  遍历当前目录，检查每个文件夹，创建一个同名的新文件夹，并将原文件夹中的文件移动到新文件夹中
####  遍历当前所有文件夹，将 、每个文件下的每一个.dart文件里的内容拷贝，然后粘贴到新建同名的.dart文件里



使用：

安装到本地：(需要Flutter环境)

dart pub global activate -sgit https://github.com/Dxc123/flutter_renewfile.git

本地移除：dart pub global deactivate flutter_renewfile

执行命令：flutter_renew files 
或者
执行命令：flutter_renew folders
