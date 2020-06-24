require_relative '../response'

# The client sends this line to indicate that it wants to disconnect.
# The server will send a ranged message to tell other user that we're disconnecting.
# The server will close the connection to the user.

class RequestDisconnect

  def initialize(line, user_data, connected_users, logger)
    @line = line
    @user_data = user_data
    @connected_users = connected_users
    @logger = logger
  end

  def process
    response = Response.new
    response.push "#TMserver:#{@user_data[:callsign]}:SEE YUH"
    response.push_mail('ranged', @line)
    response.kill_connection
    response
  end
end