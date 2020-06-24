require_relative '../response'

# The second stage of the FSD login process, for ATC clients.
# Prefixed with #AA, this line includes the users password, full name, and requested ATC rating.

class RequestLoginAuthATC

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

    @user_data[:client_type] = 'atc'

    splline = @line.split(':')
    @user_data[:full_name] = splline[2]
    @user_data[:password] = splline[4]
    @user_data[:client_atc_rating] = splline[5].to_i

    # $ERserver:unknown:006::Invalid user ID/password

    # Add this user to the connected users list
    @connected_users[@user_data[:callsign]] = @user_data[:connection_handler]

    # Add the mailbox for this user
    @user_data[:connection_handler].mailboxes[@user_data[:callsign]] = []
    response.push "#TMserver:#{@user_data[:callsign]}:[RubyFSD] Logged in! (ATC)"
    response
  end

end