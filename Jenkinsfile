node {
	stage ("Main build") {

		checkout scm

		docker.image('node:6').inside {
			stage ("Install dependencies and test") {
				sh 'cd app && npm install && npm test' 
			}
		}

	}
}
