WD_DOCKER="`cd maven/3.8.7/openjdk17;pwd`"

sh "cd ${WD_DOCKER}"
sh "docker build -t ${imageName}:${params.TAG} . "