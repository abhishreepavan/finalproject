pipelineJob('product-job') {
  definition {
    cps {
      script(readFileFromWorkspace('pipeline jobs/pubuild_job_jenkinsfile'))
      sandbox()     
    }
  }
}