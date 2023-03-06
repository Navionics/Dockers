final GIT_REPO = 'git@github.com:Navionics/Dockers.git'
final MACHINE_LABEL = 'docker-masxpb'

def getRepoURL() {
    sh "git config --get remote.origin.url > .git/remote-url"
    return readFile(".git/remote-url").trim()
}

def getCommitSha() {
    sh "git rev-parse HEAD > .git/current-commit"
    return readFile(".git/current-commit").trim()
}

def updateGithubCommitStatus(description) {
    repoUrl = getRepoURL()
    commitSha = getCommitSha()

    step([
            $class: 'GitHubCommitStatusSetter',
            reposSource: [$class: "ManuallyEnteredRepositorySource", url: repoUrl],
            commitShaSource: [$class: "ManuallyEnteredShaSource", sha: commitSha],
            errorHandlers: [[$class: 'ShallowAnyErrorHandler']],
            statusResultSource: [
                    $class: 'ConditionalStatusResultSource',
                    results: [
                            [$class: 'BetterThanOrEqualBuildResult', result: 'SUCCESS', state: 'SUCCESS', message: description],
                            [$class: 'BetterThanOrEqualBuildResult', result: 'UNSTABLE', state: 'FAILURE', message: description],
                            [$class: 'BetterThanOrEqualBuildResult', result: 'FAILURE', state: 'FAILURE', message: description],
                            [$class: 'AnyBuildResult', state: 'FAILURE', message: 'Loophole']
                    ]
            ]
    ])
}
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
                body: "Something is wrong with ${env.BUILD_URL} on branch ${env.BRANCH_NAME}, please check the log"
            )
        }
        always {
            updateGithubCommitStatus("Jenkins Job ${env.BUILD_NUMBER} - Result: ${currentBuild.currentResult} ")
            sh "export BUILD_ID=$BUILD_ID"
            cleanWs deleteDirs: true, disableDeferredWipeout: true
        }
    }
}