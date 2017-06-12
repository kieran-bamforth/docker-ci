node {
	stage ("Main build") {

		checkout scm

		docker.image('mhart/alpine-node:0.12').inside {
			stage ("Install dependencies and test") {
				sh 'cd app && npm install && npm test' 
			}
		}

	}
}
