# Docker
Generic Docker Files


## aws-cli

This Docker provides a container with the last version of the aws-cli
(it was updated to include secrets-manager service)

## ruby
Dockerfile.ruby2.3.8 provides a docker image based on ubuntu18 and ruby2.3.8. On top of this docker image we have Dockerfile.awscli_ruby.2.3.8 that install other packages including aws-cli. Use one of the two in according to your requirements.

Dockerfile.ubuntu18.04_ruby2.7.4 provides a docker image based on ubuntu18 and ruby2.7.4

Build and push docker image through Jenkins Job 
