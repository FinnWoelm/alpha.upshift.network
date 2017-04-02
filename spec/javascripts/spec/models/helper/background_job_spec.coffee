describe 'Model: BackgroundJob', ->

  sample_function = ->
    # do nothing

  beforeEach ->
    BackgroundJob.clear_all()

  afterEach ->
    BackgroundJob.clear_all()

  ## Static: Public

  describe ".add", ->

    it "adds setInterval to window with arguments", ->
      spyOn(window, 'setInterval')
      BackgroundJob.add("some-job", sample_function, 1000)
      expect(window.setInterval).toHaveBeenCalledWith(sample_function, 1000)

    it "clears any existing job with the same name", ->
      BackgroundJob.add("some-job", sample_function, 1000)
      id_of_previous_job = window.background_jobs["some-job"]

      spyOn(window, 'clearInterval')
      BackgroundJob.add("some-job", sample_function, 1000)
      expect(window.clearInterval).toHaveBeenCalledWith id_of_previous_job

    it "stores the ID of the interval in window.background_jobs", ->
      spyOn(window, 'setInterval').and.returnValue('JOBID')
      BackgroundJob.add("some-job", sample_function, 1000)
      expect(window.background_jobs['some-job']).toEqual 'JOBID'


  describe ".stop", ->

    job_ids = {}

    beforeEach ->
      BackgroundJob.add("some-job1", sample_function, 1000)
      job_ids = $.extend {}, window.background_jobs

    it "stops the job", ->
      spyOn(window, 'clearInterval')
      BackgroundJob.stop("some-job1")
      expect(window.clearInterval).toHaveBeenCalledWith(job_ids['some-job1'])


  describe ".clear_all", ->

    job_ids = {}

    beforeEach ->
      BackgroundJob.add("some-job1", sample_function, 1000)
      BackgroundJob.add("some-job2", sample_function, 1000)
      BackgroundJob.add("some-job3", sample_function, 1000)
      job_ids = $.extend {}, window.background_jobs

    it "clears each job with clearInterval", ->
      spyOn(window, 'clearInterval')
      BackgroundJob.clear_all()
      expect(window.clearInterval).toHaveBeenCalledWith(job_ids['some-job1'])
      expect(window.clearInterval).toHaveBeenCalledWith(job_ids['some-job2'])
      expect(window.clearInterval).toHaveBeenCalledWith(job_ids['some-job3'])

    it "resets window.background_jobs", ->
      BackgroundJob.clear_all()
      expect(window.background_jobs).toEqual {}
