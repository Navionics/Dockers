WD_DOCKER="`cd ./maven/3.8.7/openjdk17/;pwd`"

cd ${WD_DOCKER}
docker build -t ${imageName}:${params.TAG} .