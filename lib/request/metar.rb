require 'net/http'

require_relative '../response'

# Gets a metar from https://tgftp.nws.noaa.gov/data/observations/metar/stations/
# Then sends to the user

class RequestMETAR

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
    icao = splline[3].upcase

    uri = URI("https://tgftp.nws.noaa.gov/data/observations/metar/stations/#{icao}.TXT")
    metar = Net::HTTP.get(uri).split("\n")[1]
    @logger.debug metar

    response = Response.new
    response.push("$ARserver:#{@user_data['callsign']}:METAR:#{metar}")
    response
  end

end