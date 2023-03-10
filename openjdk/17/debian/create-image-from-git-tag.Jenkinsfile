final GIT_REPO = 'git@github.com:Navionics/Dockers.git'
final MACHINE_LABEL = 'docker-masxpb'

pipeline {
    agent { label MACHINE_LABEL}
    parameters {
        booleanParam(name: 'DO_DOCKER_UPLOAD', defaultValue: true, description: 'Perform the release on dockerHub')
        gitParameter name: 'TAG',
                     type: 'PT_TAG',
                     sortMode: 'DESCENDING_SMART',
                     description: 'Select your tag.'
    }
    options {
        timeout(time: 1, unit: 'HOURS')
        disableConcurrentBuilds()
    }
    environment {
        imageName = "navionics/openjdk"
        imageVersion = "${params.TAG}"    
    }
    stages {
        stage('CleanUp') {
            steps {
                deleteDir()
                cleanWs deleteDirs: true, disableDeferredWipeout: true
                checkout([$class: 'GitSCM',
                          branches: [[name: "${params.TAG}"]],
                          doGenerateSubmoduleConfigurations: false,
                          extensions: [],
                          gitTool: 'Default',
                          submoduleCfg: [],
                          userRemoteConfigs: [
                                  [credentialsId: '03ce9989-445b-437a-868c-64293e2c1de6',
                                   url          : GIT_REPO]
                          ]
                ])
            }
        }
        stage('Build Image ') {
            steps{
                sh "docker build -f ./openjdk/17/debian/Dockerfile -t ${imageName}:${params.TAG} ."
            }
        }
        stage('Push Image ') {
            when {
                expression {
                   return params.DO_DOCKER_UPLOAD == true
                }
            }
            steps{
                sh "docker push ${imageName}:${params.TAG}"
            }
        }
        stage('Remove Unused docker image') {
            steps{
                sh "docker rmi ${imageName}:${params.TAG}"
            }
        }
    }
    post {
        failure {
            emailext( attachLog: true,
                compressLog: true,
                recipientProviders: [culprits()],
                subject: "[${currentBuild.projectName}] Failed Pipeline: ${currentBuild.fullDisplayName}",
                body: "Something is wrong with ${env.BUILD_URL} on tag ${params.TAG}, please check the log"
            )
        }
        always {
            cleanWs deleteDirs: true, disableDeferredWipeout: true
        }
    }
}
