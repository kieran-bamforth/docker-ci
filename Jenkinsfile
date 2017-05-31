pipeline {
    agent any 

    stages {
        stage('build') { 
            docker.image('node:6').inside { 
                sh 'npm install && npm test' 
            }
        }
    }
}
