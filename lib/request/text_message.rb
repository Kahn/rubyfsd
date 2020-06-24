require_relative '../response'

# Text messages between users. Includes DMs, ATC channel messages, broadcast messages, and normal frequency messages.

class RequestTextMessage

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
    if splline[1] == '*'
      @logger.debug('Broadcast message')
      response.push_mail('broadcast', @line)
    elsif splline[1] == '@49999'
      @logger.debug('ATC chat message')
      response.push_mail('ranged_atc', @line)
    elsif splline[1].start_with? '@'
      # for now all frequency messages are just sent ranged. Its up to the client to display them or not.
      @logger.debug('Frequency message')
      response.push_mail('ranged', @line)
    elsif @connected_users.keys.include? splline[1]
      # direct message to another user
      @logger.debug('Direct message')
      @user_data[:connection_handler].mailboxes[splline[1]].push @line
    else
      return Response.empty
    end
    response
  end
end