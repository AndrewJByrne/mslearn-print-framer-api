#!/bin/bash

apiappname=PrintFramerAPI$(openssl rand -hex 5)

echo " "
echo "Set username and password email for Git"
echo " "

GIT_USERNAME=gitName$Random
GIT_EMAIL=a@b.c

git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"


RESOURCE_GROUP=$(az group list --query "[0].name" -o tsv)

# Create App Service plan
PLAN_NAME=myPlan

echo " "
echo "Create App Service plan in FREE tier"
echo " "

az appservice plan create --name $apiappname --resource-group $RESOURCE_GROUP --sku FREE --verbose

echo " "
echo "Create API App"
echo " "

az webapp create --name $apiappname --resource-group $RESOURCE_GROUP --plan $apiappname --deployment-local-git --verbose

echo " "
echo "Set the account-level deployment credentials"
echo " "

DEPLOY_USER="myName1$(openssl rand -hex 5)"
DEPLOY_PASSWORD="Pw1$(openssl rand -hex 10)"

az webapp deployment user set --user-name $DEPLOY_USER --password $DEPLOY_PASSWORD --verbose


GIT_URL="https://$DEPLOY_USER@$apiappname.scm.azurewebsites.net/$apiappname.git"

# Create Web App with local-git deploy

REMOTE_NAME=production

echo " "
# Set remote on src
echo "Set Git remote"

echo " "
git remote add $REMOTE_NAME $GIT_URL

echo " "
echo "Git add"
echo " "

git add .
git commit -m "initial revision"

echo " "
echo "Git push"
echo " "

echo "When prompted for a password enter this: $DEPLOY_PASSWORD"
git push --set-upstream $REMOTE_NAME master

echo " "
echo "Setup complete"
echo " "

echo "Swagger URL: https://$apiappname.azurewebsites.net/swagger"
echo "Example URL: https://$apiappname.azurewebsites.net/api/values/6/7"
