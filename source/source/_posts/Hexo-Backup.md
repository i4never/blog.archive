---
title: Hexo Backup
date: 2017-04-01 11:41:43
tags: [Shell, Git]
categories: [Others]
---

这个Blog用Hexo搭建，由Hexo生成静态页面，deploy到githubIO（也可以是自己搭建的服务器）上后以供访问。但是如果遇到需要更换电脑的情况，如果不加备份，github的repository里只有生成的静态页面，所用的theme，原始的.md以及_config.yml等等都会丢失，Blog也就没办法迁移和复原了。

<!--more-->

## Thoughts
看了知乎上的这个[回答][1]，各种备份的方法，甚至有打包做成[npm插件][2]的，但是从issues中的各种问题来看不太成熟。除了各种云盘u盘备份文件夹，剩余的方法基本是新开一个git branch，然后通过各种方法把各种内容都push到这个branch上，但是关于push哪些内容有不小的差异。

首先对于一个blog，最重要的就是写的article了吧，Hexo结构下，博文都在根目录下的``source/``中，这是一个要备份的内容。

其次是站点的``_config.yml``以及所用的主题``themes/``。Hexo的宗旨就是让你可以在30分钟内快速搭建一个博客，也可以花上一整天折腾各种细节，折腾的细节就在这些文件里了。

最后，是blog的各种插件。大部分好像都备份了``node_modules/``这个文件，一看有80MB左右，感觉太不轻巧。既然nodeJS这么普及，那么应该也有像pip这样的包管理工具（npm）。在根目录下运行：
``npm init``
一路回车和yes之后，会在根目录下生成一个package.json文件（相当于pip freeze的requirments）：
```json
{
  "name": "hexo-site",
  "version": "0.0.0",
  "private": true,
  "hexo": {
    "version": "3.2.2"
  },
  "dependencies": {
    "hexo": "^3.2.0",
    "hexo-addlink": "^1.0.4",
    "hexo-deployer-git": "^0.2.0",
    "hexo-generator-archive": "^0.1.4",
    "hexo-generator-category": "^0.1.3",
    "hexo-generator-index": "^0.2.0",
    "hexo-generator-tag": "^0.2.0",
    "hexo-renderer-ejs": "^0.2.0",
    "hexo-renderer-marked": "^0.2.11",
    "hexo-renderer-stylus": "^0.3.1",
    "hexo-server": "^0.2.0"
  },
  "main": "index.js",
  "devDependencies": {},
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "description": ""
}

```
如果迁移了，在新环境下安装nodeJS与npm之后，有了package.json，在该目录下``npm install``之后就会安装各种包和依赖。

## Solution
### Backup
 1. 在repository:yourgitid.io中新建一个名为hexo的branch
 2. 在blog的根目录``git clone xxxxxxxx``。
 3. 进入刚才clone的库，切换到新分支上``git checkout hexo``
 4. 把分支上原来的文件都删掉``rm -rf *``
 5. 运行下面的脚本，该脚本会备份``themes/ _config.yml source/ package.json``以及备份脚本自己``backup.sh``
```shell
#/bin/bash

echo -e "\033[31m===========================================\033[0m" 
echo "This script is for backup hexo blog"
echo "The following file will be uploaded:"
echo -e "   \033[32m./themes\033[0m"
echo -e "   \033[32m_config.yml\033[0m"
echo -e "   \033[32m./source\033[0m"
echo -e "   \033[32mpackage.json\033[0m"
echo -e "   \033[32mbackup.sh\033[0m"
echo -e "\033[31m===========================================\033[0m"

echo -e "Change branch to \"hexo\""
cd i4never.github.io
# git checkout hexo
 
cp -r ../themes ./themes
cp ../_config.yml ./_config.yml
cp ../package.json ./package.json
cp ../backup.sh ./backup.sh
cp -r ../source ./source

d="`date +%Y-%m-%d-%H:%M:%S`"

git add .
git commit -m $d
git push origin hexo

echo -e "\033[31m===========================================\033[0m"
echo "The following files bs been uploaded:"
echo -e "       \033[32m./themes\033[0m"
echo -e "       \033[32m_config.yml\033[0m"
echo -e "       \033[32m./source\033[0m"
echo -e "       \033[32mpackage.json\033[0m"
echo -e "       \033[32mbackup.sh\033[0m"
echo -e "\033[31m===========================================\033[0m"
```
第一次写shell脚本，应该有不地道的地方。

### Recover
 1. 新环境下安装nodeJS与npm
 2. 执行``hexo init``
 3. clone git repository，转换到hexo分支
 4. 替换``themes/ source/ _config.yml``这三个文件
 5. ``hexo g && hexo d``
此外新环境的git要事先设置好，尤其是ssh key，否则会导致deploy失败。


[1]: https://www.zhihu.com/question/21193762
[2]: https://github.com/coneycode/hexo-git-backup
