class @BackgroundJob

  # Methods
  #
  #/ Static: Public
  #// add: adds a job with name/ID, function, and interval
  #// stop: stops a job with name/ID
  #// clear_all: removes all jobs

  @add: (ID, job_function, job_interval) ->

    window.background_jobs ||= {}

    window.clearInterval window.background_jobs[ID]

    window.background_jobs[ID] = window.setInterval(job_function, job_interval)


  @stop: (ID) ->

    window.clearInterval window.background_jobs[ID]


  @clear_all: ->

    for job_name, job_id of window.background_jobs
      window.clearInterval job_id

    window.background_jobs = {}
