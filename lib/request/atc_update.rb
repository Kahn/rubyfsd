require_relative '../response'

# An ATC update, prefixed with %, includes tuned frequency, atc position, visibility range, and lat/lon location.

class RequestATCUpdate

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

    response = Response.new
    splline = @line.split(':')
    @user_data[:frequency] = splline[1]
    @user_data[:client_atc_position] = splline[2].to_i
    @user_data[:visibility_range] = splline[3].to_i
    @user_data[:location] = [splline[5], splline[6]]
    response.push_mail('ranged', @line)
    response
  end

end