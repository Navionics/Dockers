WD_DOCKER="`cd ./maven/3.8.7/openjdk17/;pwd`"
IMAGE_ID=navionics/${projectName}:${imageVersion}

cd ${WD_DOCKER}
docker build -t ${IMAGE_ID} .