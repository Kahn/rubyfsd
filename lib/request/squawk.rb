require_relative '../response'

# ATC *amendment* of an assigned squawk code

class RequestSquawkAmend

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

    splline = @line.split(':')
    callsign = splline[3]
    squawk = splline[4]

    if @connected_users[callsign].nil? || !@connected_users[callsign].user_data[:flightplan][:exists?]
      return Response.empty
    else
      @connected_users[callsign].user_data[:flightplan][:assigned_squawk] = squawk

      response = Response.new
      response.push_mail('ranged_atc', "#PCserver:@94835:CCP:BC:#{callsign}:#{squawk}")
      response
    end
  end
end
