require_relative '../response'

# ATC flightplan amendment

class RequestFlightplanAmend

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
    callsign = splline[2]
    if @connected_users[callsign].nil? || !@connected_users[callsign].user_data[:flightplan][:exists?]
      return Response.empty
    else
      flightplan = @connected_users[callsign].user_data[:flightplan]

      flightplan[:flight_rules] = splline[3]
      flightplan[:aircraft_type] = splline[4]
      flightplan[:departure_airport] = splline[6]
      flightplan[:arrival_airport] = splline[10]
      flightplan[:cruise_altitude] = splline[9]
      flightplan[:alternate] = splline[15]
      flightplan[:remarks] = splline[16]
      flightplan[:route] = splline[17]

      flightplan[:exists?] = true

      response = Response.new
      response.push_mail('ranged_atc', "$FP#{callsign}:#{@user_data[:callsign]}:#{flightplan[:flight_rules]}:#{flightplan[:aircraft_type]}:450:#{flightplan[:departure_airport]}:0:0:#{flightplan[:cruise_altitude]}:#{flightplan[:arrival_airport]}:0:0:0:0:#{flightplan[:alternate]}:#{flightplan[:remarks]}:#{flightplan[:route]}")
      return response
    end
  end
end
