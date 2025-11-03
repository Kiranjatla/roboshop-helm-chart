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

    // --- NEW STAGE ADDED HERE ---
        stage('Install External Secrets Operator') {
          steps {
            echo 'Installing External Secrets Operator...'
            sh '''
              # Add the official ESO Helm repository
              helm repo add external-secrets https://charts.external-secrets.io

              # Update local cache
              helm repo update

              # Install the operator. Using 'upgrade --install' is idempotent.
              # We deploy it into its own 'external-secrets' namespace for isolation.
              helm upgrade --install external-secrets external-secrets/external-secrets \
                --create-namespace --namespace external-secrets
            '''
          }
        }
        // --- END NEW STAGE ---

    stage('Helm Deploy') {
      steps {
        sh '''
          helm upgrade -i ${component} . -f APP/helm/prod.yml --set-string componentName=${component} --set-string appVersion=${appVersion}
        '''
      }
    }

  }

}