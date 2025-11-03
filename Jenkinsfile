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

          # 1. Upgrade the operator in the kube-system namespace
          helm upgrade --install external-secrets external-secrets/external-secrets \
            -n kube-system \
            --set crds.enabled=false

          # 2. Wait for the ESO deployment to be ready
          echo "Waiting for External Secrets Operator deployment to be ready..."
          kubectl -n kube-system wait --for=condition=available deployment/external-secrets --timeout=60s

          # 3. Force API Client Cache Refresh (for redundancy)
          echo "Verifying CRD establishment and forcing API client cache refresh..."
          kubectl get crd externalsecrets.external-secrets.io
          kubectl api-resources
          sleep 5
        '''
      }
    }

    stage('Helm Deploy') {
      steps {
        echo 'Deploying application using helm template + kubectl apply to bypass CRD recognition issues...'
        sh '''
          # 1. Render the Helm chart to a YAML file
          # We use a non-interactive Helm command to generate the final manifest.
          helm template ${component} . -f APP/helm/prod.yml \
            --set-string componentName=${component} \
            --set-string appVersion=${appVersion} \
            > ${component}-manifest.yaml

          # 2. Apply the manifest using kubectl, which successfully recognizes the CRD.
          kubectl apply -f ${component}-manifest.yaml
        '''
      }
    }

  }

}
