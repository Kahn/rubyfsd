require_relative '../response'

# $CQ request for a users flightplan

class RequestFlightplanGet

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

    if @connected_users[callsign].nil? || !@connected_users[callsign].user_data[:flightplan][:exists?]
      return Response.empty
    else
      response = Response.new
      flightplan = @connected_users[callsign].user_data[:flightplan]
      response.push("$FP#{callsign}:#{@user_data[:callsign]}:#{flightplan[:flight_rules]}:#{flightplan[:aircraft_type]}:450:#{flightplan[:departure_airport]}:0:0:#{flightplan[:cruise_altitude]}:#{flightplan[:arrival_airport]}:0:0:0:0:#{flightplan[:alternate]}:#{flightplan[:remarks]}:#{flightplan[:route]}")
      response.push("#PCserver:#{@user_data[:callsign]}:CCP:BC:#{callsign}:#{flightplan[:assigned_squawk]}")
      response.push("$CQSERVER:@94835:SC:#{callsign}:#{flightplan[:scratchpad]}")
      response
    end
  end
end
