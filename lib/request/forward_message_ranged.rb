require_relative '../response'

# An Pilot update, prefixed with @, includes lat/lon location, transponder mode/code, altitudes, pitch, bank, groundspeed.

class RequestForwardMessageRanged

  def initialize(line, user_data, connected_users, logger)
    @line = line
    @user_data = user_data
    @connected_users = connected_users
    @logger = logger
  end

  def process
    unless @user_data[:logged_in]
      return Response.empty
    end

    response = Response.new
    response.push_mail('ranged', @line)
    response
  end

end