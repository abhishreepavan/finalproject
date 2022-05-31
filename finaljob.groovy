pipelineJob('aws') {
  definition {
    cps {
      script(readFileFromWorkspace('pipeline jobs/ansible_pipeline_Jenkinsfile'))
      sandbox()     
    }
  }
}
pipelineJob('buidling docker image and pushing it to ECR') {
  definition {
    cps {
      script(readFileFromWorkspace('pipeline jobs/build_job_jenkinsfile'))
      sandbox()     
    }
  }
}
pipelineJob('running a docker image') {
  definition {
    cps {
      script(readFileFromWorkspace('pipeline jobs/deploy_job_jenkinsfile'))
      sandbox()     
    }
  }
}
