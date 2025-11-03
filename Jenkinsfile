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
          helm repo add external-secrets https://charts.external-secrets.io || true
          helm repo update

          # Targetting the 'kube-system' namespace to match the Terraform installation.
          helm upgrade --install external-secrets external-secrets/external-secrets \
            -n kube-system \
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
```
eof

I removed the conflicting comment:
```groovy
# IMPORTANT: If your app needs the ClusterSecretStore to be created in the target namespace,
# you might need to add the namespace flag here too, but for now, we'll keep it simple
# as the deployment will go to the default namespace if not specified.
