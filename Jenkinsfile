pipeline {
  agent any

  parameters {
    string(name: 'component', defaultValue: '', description: 'Component Name')
    string(name: 'appVersion', defaultValue: '', description: 'Component appVersion')
  }

  stages {

    stage('CheckOut Application Code') {
      steps {
        dir('APP') {
          git branch: 'main', url: "https://github.com/Kiranjatla/${component}"
        }
      }
    }

    stage('Install External Secrets Operator') {
          steps {
            echo 'Installing External Secrets Operator...'
            sh '''
              # Add the official ESO Helm repository
              helm repo add external-secrets https://charts.external-secrets.io

              # Update local cache
              helm repo update

              # FIX: Set crds.enabled=false to prevent the Helm release from trying
              # to manage CRDs that already exist, thus avoiding the ownership conflict error.
              helm upgrade --install external-secrets external-secrets/external-secrets \
                --create-namespace --namespace external-secrets \
                --set crds.enabled=false
            '''
          }
        }

    stage('Helm Deploy') {
      steps {
        sh '''
          helm upgrade -i ${component} . -f APP/helm/prod.yml --set-string componentName=${component} --set-string appVersion=${appVersion}
        '''
      }
    }

  }

}