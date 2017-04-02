class @ExactDate

  # ExactDate is an extension of the Date object.
  # It has support for microseconds and for parsing Rails timestamps.
  #
  # Methods
  #
  #/ Static: Public
  #// parse: takes a Rails timestamp and parses it to create a new object
  #//        instance
  #
  #/ Instance: Public
  #// add: returns a new instance of ExactDate incremented by a number of
  #//      microseconds
  #// to_f: converts the ExactDate to a float value (# of microseconds)
  #// to_s: formats the ExactDate to a string (YYYY-MM-DD HH:MM:SS.MMMMMM +0000)
  #
  #/ Instance: Private
  #// timezone_to_microseconds: converts the timezone into an integer
  #//                           representing the timezone offset in microseconds

  @MICROSECOND = 1
  @MILLISECOND = 1000 * @MICROSECOND
  @SECOND = 1000 * @MILLISECOND
  @MINUTE = 60 * @SECOND
  @HOUR = 60 * @MINUTE
  @DAY = 24 * @HOUR


  #########################
  # Static Public Methods #
  #########################


  constructor: (@time_in_microseconds, @timezone = "+0000") ->



  # takes a Rails timestamp and parses it to create a new object
  # instance
  @parse: (timestamp) ->

    timestamp = timestamp.split(" ")
    date = timestamp[0].split("-")

    # replace millisecond/microsecond delimiter with :
    time = timestamp[1].split(".")[0].split(":")
    millisecond = timestamp[1].split(".")[1].substr(0, 3)
    microsecond = timestamp[1].split(".")[1].substr(3, 6)

    # get zone
    zone = timestamp[2]

    return new ExactDate(
      Date.UTC(
        parseInt(date[0]),
        parseInt(date[1]) - 1,
        parseInt(date[2]),
        parseInt(time[0]),
        parseInt(time[1]),
        parseInt(time[2]),
        parseInt(millisecond)
      ) * 1000 +
      parseInt(microsecond),
      zone
    )


  ###########################
  # Public Instance Methods #
  ###########################


  # returns a new instance of ExactDate incremented by a number of microseconds
  add: (microseconds) ->
    return new ExactDate(@time_in_microseconds + microseconds, @timezone)


  # converts the ExactDate to a float value (# of microseconds)
  to_f: ->
    return @time_in_microseconds + @_timezone_to_microseconds()


  # formats the ExactDate to a string (YYYY-MM-DD HH:MM:SS.MMMMMM +0000
  to_s: ->
    date = new Date(Math.floor(@time_in_microseconds/1000))

    year = date.getUTCFullYear()
    month = ("0" + (date.getUTCMonth()+1)).substr(-2)
    day = ("0" + date.getUTCDate()).substr(-2)

    hour = ("0" + date.getUTCHours()).substr(-2)
    minute = ("0" + date.getUTCMinutes()).substr(-2)
    second = ("0" + date.getUTCSeconds()).substr(-2)
    milliseconds = ("00" + date.getUTCMilliseconds()).substr(-3)
    microseconds = "00#{@time_in_microseconds}".substr(-3)

    return "#{year}-#{month}-#{day} #{hour}:#{minute}:#{second}.#{milliseconds}#{microseconds} #{@timezone}"


  ############################
  # Private Instance Methods #
  ############################


  # converts the timezone into an integer representing the timezone offset in
  # microseconds
  _timezone_to_microseconds: ->
    symbol = @timezone.substr(0, 1)
    hour   = @timezone.substr(1, 2)
    minute = @timezone.substr(-2)

    return (parseInt(hour) * ExactDate.HOUR + parseInt(minute) * ExactDate.MINUTE) * -1 * parseInt(symbol+"1")
