require_relative '../response'

# ATC *amendment* of a scratchpad code.

class RequestScratchpadAmend

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
    scratchpad = splline[4]
    if @connected_users[callsign].nil? || !@connected_users[callsign].user_data[:flightplan][:exists?]
      return Response.empty
    else
      @connected_users[callsign].user_data[:flightplan][:scratchpad] = scratchpad

      response = Response.new
      response.push_mail('ranged_atc', "$CQSERVER:@94835:SC:#{callsign}:#{scratchpad}")
      response
    end
  end
end
