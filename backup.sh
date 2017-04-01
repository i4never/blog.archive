#/bin/bash

echo -e "\033[31m===========================================\033[0m" 
echo "This script is for backup hexo blog"
echo -e "\033[31m===========================================\033[0m"
echo "The following file will be uploaded:"
echo -e "	\033[32m./themes\033[0m"
echo -e "	\033[32m_config.yml\033[0m"
echo -e "	\033[32m./source\033[0m"
echo -e "	\033[32mpackage.json\033[0m"
echo -e "	\033[32mbackup.sh\033[0m"

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
