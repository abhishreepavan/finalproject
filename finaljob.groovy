pipelineJob('product-job') {
  definition {
    cps {
      script(readFileFromWorkspace('pipeline jobs/build_job_jenkinsfile'))
      sandbox()     
    }
  }
}
