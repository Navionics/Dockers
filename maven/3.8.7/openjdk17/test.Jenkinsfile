final GIT_REPO = 'git@github.com:Navionics/webapi-reports.git'
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
        booleanParam(name: 'DO_DEPLOY', defaultValue: true, description: 'Perform the deploy in beta environment')
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
        imageName = "navionics/webapi-reports"
	    AWS_SECRET_ACCESS_KEY = credentials('webapi-reports_aws_secret_access_key')
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
        stage('Prepare Env') {
            steps {
               sh "./environments/scripts/start_env.sh -f -s test"
            }
        }
        stage('Package and Deploy Git TAG as Artifacts') {
            agent {
                dockerfile {
                    filename './environments/jenkins/jenkins.Dockerfile'
                    label MACHINE_LABEL
                    args " --network='webapi-reports-be-network'  --link='mysql_webapi-reports' "
                    reuseNode true
                }
            }
            steps {
                withCredentials([
                    usernamePassword(credentialsId: '8c7b1b3b-651e-413b-be60-7715749bdce4', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USER'),
                    usernamePassword(credentialsId: 'd625b3f5-a463-4067-83fd-9053eb95e120', passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USER'),
                    usernamePassword(credentialsId: 'webapi-reports-beta-dev', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')
                ]) {
                    checkout([$class: 'GitSCM',
                              branches: [[name: "${params.TAG}"]],
                              doGenerateSubmoduleConfigurations: false,
                                extensions: [],
                                gitTool: 'Default',
                                submoduleCfg: [],
                              userRemoteConfigs: [
                                      [credentialsId: '03ce9989-445b-437a-868c-64293e2c1de6',
                                       url          : 'git@github.com:Navionics/webapi-reports.git']
                              ]
                    ])
                    sh 'cat pom.xml'
                    sh 'mvn -U -s ./environments/jenkins/jenkins-settings.xml -gs ./environments/jenkins/jenkins-settings.xml -P test clean deploy'
                    junit '**/target/*reports/*.xml'
                }
            }
        }
         stage('Building Docker image') {
            environment {
                imageVersion = "${params.TAG}"
            }
            steps{
                withCredentials([
                usernamePassword(credentialsId: 'd625b3f5-a463-4067-83fd-9053eb95e120', passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USER'),
                    usernamePassword(credentialsId: 'webapi-reports-beta-dev', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')
                ]){
                    sh './environments/scripts/build-docker-image.sh'
                }
            }
        }
        stage('Push Image ') {
            steps{
                sh "docker push ${imageName}:${params.TAG}"
            }
        }
        stage('Remove Unused docker image') {
            steps{
                sh "docker rmi ${imageName}:${params.TAG}"
            }
        }
        stage('Deploy Image') {
            when {
                expression {
                   return params.DO_DEPLOY == true
                }
            }
            steps {
                build job: 'webapi-reports-deploy-beta',
                    parameters: [
                        string(name: 'TAG', value: "${params.TAG}"),
                        string(name: 'COUNT', value: "1")
                    ],
                    wait: true
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
            sh "./environments/scripts/stop_env.sh -s test"
            cleanWs deleteDirs: true, disableDeferredWipeout: true
        }
    }
}