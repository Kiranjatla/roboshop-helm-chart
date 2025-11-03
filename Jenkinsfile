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
          // Checkout the specific component code based on the parameter
          git branch: 'main', url: "https://github.com/Kiranjatla/${component}"
        }
      }
    }

    stage('Install External Secrets Operator') {
      steps {
        echo 'Ensuring External Secrets Operator is installed...'
        sh '''
          helm repo add external-secrets https://charts.external-secrets.io || true
          helm repo update

          # Targetting the 'kube-system' namespace to match the Terraform installation
          # and setting crds.enabled=false to resolve the CRD ownership conflict.
          helm upgrade --install external-secrets external-secrets/external-secrets \
            -n kube-system \
            --set crds.enabled=false
        '''
      }
    }

    stage('Helm Deploy') {
      steps {
        // Deploy the specific application component using its values file
        sh '''
          helm upgrade -i ${component} . -f APP/helm/prod.yml --set-string componentName=${component} --set-string appVersion=${appVersion}
        '''
      }
    }

  }

}
