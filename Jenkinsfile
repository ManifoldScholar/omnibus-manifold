pipeline {
  agent {
    node {
      label 'ubuntu16'
    }
    
  }
  stages {
    stage('Build') {
      steps {
        git(url: 'https://github.com/ManifoldScholar/omnibus-manifold', branch: 'master', poll: true)
      }
    }
  }
}