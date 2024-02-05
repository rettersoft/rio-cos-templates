#! /bin/bash

set -e

cd ~
pwd
whoami

echo "installing nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

echo "nvm version: "
nvm -v

echo "installing node"
nvm install 20.11.0
echo "node version: "
node -v

echo "installing pm2"
npm install pm2 -g
echo "pm2 version: "
pm2 -v

echo "getting source"
AWS_ACCESS_KEY_ID=$accessKeyId AWS_SECRET_ACCESS_KEY=$secretAccessKey AWS_DEFAULT_REGION=$region aws s3api get-object --bucket rio-deployer-$stage --key releases/rio_project_deployer.zip "rio_project_deployer.zip"
unzip -q -d rio_project_deployer rio_project_deployer.zip

echo "configuring pm2"
cd rio_project_deployer
sed -e "s/{{ACCESS_KEY_ID}}/$accessKeyId/g" -e "s/{{SECRET_ACCESS_KEY}}/$secretAccessKey/g" -e "s/{{REGION}}/$region/g" -e "s/{{STAGE}}/$stage/g" "ecosystem.config.js" > "temp_ecosystem.config.js"
mv temp_ecosystem.config.js ecosystem.config.js

npm i @swc/cli @swc/core --silent --save-dev

cp package.json dist/.

echo "starting pm2"
pm2 startup | bash
pm2 start ecosystem.config.js
pm2 save
