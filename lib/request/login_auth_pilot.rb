require_relative '../response'

# The second stage of the FSD login process, for Pilot clients.
# Prefixed with #AP

class RequestLoginAuthPilot

  def initialize(line, user_data, connected_users, logger)
    @line = line
    @user_data = user_data
    @connected_users = connected_users
    @logger = logger
  end

  def process
    unless @user_data[:id_complete?]
      return Response.empty
    end

    response = Response.new

    @user_data[:client_type] = 'pilot'

    splline = @line.split(':')
    @user_data[:full_name] = splline[7]
    @user_data[:password] = splline[3]
    @user_data[:visibility_range] = 5

    # Add this user to the connected users list
    @connected_users[@user_data[:callsign]] = @user_data[:connection_handler]

    # Add the mailbox for this user
    @user_data[:connection_handler].mailboxes[@user_data[:callsign]] = []
    response.push "#TMserver:#{@user_data[:callsign]}:[RubyFSD] Logged in! (Pilot)"
    response
  end

end