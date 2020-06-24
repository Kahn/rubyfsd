require_relative '../response'

# Requests full name of another online user

class RequestFullName

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
    if @connected_users[splline[1]].nil?
      Response.empty
    else
      response = Response.new
      response.push("$CR#{splline[1]}:#{@user_data[:callsign]}:RN:#{@connected_users[splline[1]].user_data[:full_name]}::1")
      response
    end
  end
end