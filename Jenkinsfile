pipeline {
  agent any

  environment {
    DOCKERHUB_USER = 'delibms'
    IMAGE          = "${DOCKERHUB_USER}/tomcat-app"
    TAG            = "${env.BUILD_NUMBER}"
    AWS_REGION     = 'ap-south-1'
    CLUSTER        = 'tomcat-eks'
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build image') {
      steps {
        sh "docker build -t ${IMAGE}:${TAG} -t ${IMAGE}:latest ."
      }
    }

    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                          usernameVariable: 'DH_USER',
                                          passwordVariable: 'DH_PASS')]) {
          sh 'echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin'
          sh "docker push ${IMAGE}:${TAG}"
          sh "docker push ${IMAGE}:latest"
        }
      }
    }

    stage('Deploy to EKS') {
      steps {
        // Jenkins server uses an IAM role that is allowed to access the cluster
        sh "aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER}"
        sh "kubectl apply -f k8s/"
        sh "kubectl set image deployment/tomcat-app tomcat=${IMAGE}:${TAG}"
        sh "kubectl rollout status deployment/tomcat-app --timeout=180s"
      }
    }
  }

  post {
    always { sh "docker logout || true" }
  }
}
