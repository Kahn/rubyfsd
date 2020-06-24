require_relative '../response'

# Forward a line directly to another user

class RequestForwardMessageDirect

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
    recipient = splline[1]
    response.push_mail('direct', @line, recipient)
    response
  end

end