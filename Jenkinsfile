pipeline {
  agent {
    node {
      label 'build'
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