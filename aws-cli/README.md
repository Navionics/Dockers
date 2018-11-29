##Example of usage

CMD="ecs update-service --cluster ${CLUSTER} --service ${SERVICE} --task-definition ${TASK}:${REVISION} --force-new-deployment"
docker run -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" -e "AWS_DEFAULT_REGION=us-east-1"  mesosphere/aws-cli ${CMD}
