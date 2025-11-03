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
        echo 'Ensuring External Secrets Operator is installed...'
        sh '''
          helm repo add external-secrets https://charts.external-secrets.io || true
          helm repo update

          # 1. Upgrade the operator in the kube-system namespace (CRDs already exist from Terraform)
          helm upgrade --install external-secrets external-secrets/external-secrets \
            -n kube-system \
            --set crds.enabled=false

          # 2. Wait for the ESO deployment to be ready
          echo "Waiting for External Secrets Operator deployment to be ready..."
          kubectl -n kube-system wait --for=condition=available deployment/external-secrets --timeout=60s

          # 3. Force API Client Cache Refresh
          echo "Forcing API client cache refresh..."
          kubectl api-resources
          sleep 5
        '''
      }
    }

    stage('Helm Deploy') {
      steps {
        echo 'Deploying application and fixing ExternalSecret API version mismatch...'
        sh '''
          # 1. Render the Helm chart to a temporary manifest file
          helm template ${component} . -f APP/helm/prod.yml \
            --set-string componentName=${component} \
            --set-string appVersion=${appVersion} \
            > ${component}-manifest.yaml

          # 2. CRITICAL FIX: Rewrite the deprecated API version (v1beta1) to the active API version (v1)
          # This compensates for the outdated API version in the application chart.
          echo "Fixing ExternalSecret API version from v1beta1 to v1..."
          sed -i 's/external-secrets.io\\/v1beta1/external-secrets.io\\/v1/g' ${component}-manifest.yaml

          # 3. Apply the fixed manifest using kubectl.
          kubectl apply -f ${component}-manifest.yaml
        '''
      }
    }

  }

}
