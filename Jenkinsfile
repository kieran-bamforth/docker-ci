pipeline {
	agent any 

	stages {
		stage('build') { 
			steps {
				docker.image('node:6').inside { 
					sh 'npm install && npm test' 
				}
			}
		}
	}
}
