require_relative '../response'

# The client sends a $CQ request with the ATC method in order to "request" ATC control.
# This tells the client whether it is allowed to perform ATC tasks, like modifying flightplans, assigning squawks, etc.
# If the client is not allowed to perform ATC tasks, the client is most likely an observer and will be served basic information.

class RequestATCControl

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

    # For some reason clients like to ask about other users ATC-control status. Ignoring these requests for now.
    splline = @line.split(':')
    unless splline[3] == @user_data[:callsign]
      return Response.empty
    end

    response = Response.new
    if @user_data[:client_atc_position] > 0 && @user_data[:client_atc_rating] > 1
      # The client is allowed to perform ATC tasks
      response.push "$CRSERVER:#{@user_data[:callsign]}:ATC:Y:#{@user_data[:callsign]}"
    else
      # The client is NOT allowed to perform ATC tasks
      response.push "$CRSERVER:#{@user_data[:callsign]}:ATC:N:#{@user_data[:callsign]}"
    end
    response
  end
end