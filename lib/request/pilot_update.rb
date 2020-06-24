require_relative '../response'

# Pilot updates prefixed with '@' include lat/lon location, transponder mode/code, altitudes, pitch, bank, groundspeed, etc.

class RequestPilotUpdate

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
    splline = @line.split('@')[1].split(':')
    @user_data[:location] = [splline[4], splline[5]]
    if !@user_data[:sweatbox?]
      response.push_mail('ranged', @line)
      response
    else
      response.push_mail('ranged_atc', @line)
      response
    end
  end
end