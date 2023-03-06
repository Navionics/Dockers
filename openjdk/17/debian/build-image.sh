WD_DOCKER="`cd ./maven/3.8.7/openjdk17/;pwd`"
IMAGE_ID=maven-image

cd ${WD_DOCKER}
echo ${IMAGE_ID}

docker build -t ${IMAGE_ID} .