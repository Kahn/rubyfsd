require_relative '../response'

# Pilot files a flightplan to the server

class RequestFlightplanFile

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
    @user_data[:flightplan][:flight_rules] = splline[2]
    @user_data[:flightplan][:aircraft_type] = splline[3]
    @user_data[:flightplan][:departure_airport] = splline[5]
    @user_data[:flightplan][:arrival_airport] = splline[9]
    @user_data[:flightplan][:cruise_altitude] = splline[8]
    @user_data[:flightplan][:alternate] = splline[14]
    @user_data[:flightplan][:route] = splline[16]
    @user_data[:flightplan][:remarks] = splline[15]

    @user_data[:flightplan][:exists?] = true

    @logger.debug @user_data[:flightplan].inspect
    response = Response.new
    response.push_mail('ranged_atc', @line)
    response
  end
end
