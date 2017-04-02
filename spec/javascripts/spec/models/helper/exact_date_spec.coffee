describe 'Model: ExactDate', ->


  #########################
  # Static Public Methods #
  #########################


  describe ".parse", ->

    it "sets time_in_microseconds", ->
      parsed_timestamp = ExactDate.parse("2017-03-31 09:02:50.789088 +0000")
      expect(parsed_timestamp.time_in_microseconds).toEqual 1490950970789088

      parsed_timestamp = ExactDate.parse("2017-01-15 16:59:33.753256 +0400")
      expect(parsed_timestamp.time_in_microseconds).toEqual 1484499573753256

      parsed_timestamp = ExactDate.parse("2017-10-22 23:22:07.567532 -0700")
      expect(parsed_timestamp.time_in_microseconds).toEqual 1508714527567532

    it "sets timezone", ->
      parsed_timestamp = ExactDate.parse("2017-03-31 09:02:50.789088 +0600")
      expect(parsed_timestamp.timezone).toEqual "+0600"

      parsed_timestamp = ExactDate.parse("2017-03-31 09:02:50.789088 +0000")
      expect(parsed_timestamp.timezone).toEqual "+0000"

      parsed_timestamp = ExactDate.parse("2017-03-31 09:02:50.789088 -0830")
      expect(parsed_timestamp.timezone).toEqual "-0830"

    it "returns an instance of ExactDate", ->
      parsed_timestamp = ExactDate.parse("2017-03-31 09:02:50.789088 +0000")
      expect(parsed_timestamp).toEqual jasmine.any(ExactDate)


  ###########################
  # Public Instance Methods #
  ###########################


  describe "#add", ->

    date = null

    beforeEach ->
      date = ExactDate.parse("2017-03-31 09:02:50.789088 +0000")

    it "does not alter the instance itself", ->
      time_in_microseconds_before_addition = date.to_f()
      date.add(100)
      expect(date.to_f()).toEqual time_in_microseconds_before_addition

    it "returns an instance of ExactDate", ->
      expect(date.add(100)).toEqual jasmine.any(ExactDate)

    it "returns an instance of ExactDate with increased time_in_microseconds", ->
      expect(date.add(100).to_f()).toEqual date.to_f() + 100


  describe "#to_f", ->

    it "returns 1508714527567532", ->
      date = new ExactDate(1508714527567532, "+0000")
      expect(date.to_f()).toEqual 1508714527567532

    it "returns 1484485173753256", ->
      date = new ExactDate(1484499573753256, "+0400")
      expect(date.to_f()).toEqual 1484485173753256

    it "returns 1508739727567532", ->
      date = new ExactDate(1508714527567532, "-0700")
      expect(date.to_f()).toEqual 1508739727567532


  describe "#to_s", ->

    it "returns '2017-03-31 09:02:50.789088 +0000'", ->
      date = new ExactDate(1490950970789088, "+0000")
      expect(date.to_s()).toEqual "2017-03-31 09:02:50.789088 +0000"

    it "returns '2017-01-15 16:59:33.753256 +0400'", ->
      date = new ExactDate(1484499573753256, "+0400")
      expect(date.to_s()).toEqual "2017-01-15 16:59:33.753256 +0400"

    it "returns '2017-10-22 23:22:07.567532 -0700'", ->
      date = new ExactDate(1508714527567532, "-0700")
      expect(date.to_s()).toEqual "2017-10-22 23:22:07.567532 -0700"


  ############################
  # Private Instance Methods #
  ############################


  describe "#_timezone_to_microseconds", ->

    it "returns 0", ->
      date = new ExactDate(1490950970789.088, "+0000")
      expect(parseInt(date._timezone_to_microseconds())).toEqual 0

    it "returns -16200000", ->
      date = new ExactDate(1490950970789.088, "+0430")
      expect(date._timezone_to_microseconds()).toEqual -(4*ExactDate.HOUR + 30*ExactDate.MINUTE)

    it "returns +241920000", ->
      date = new ExactDate(1490950970789.088, "-6712")
      expect(date._timezone_to_microseconds()).toEqual (67*ExactDate.HOUR + 12*ExactDate.MINUTE)
