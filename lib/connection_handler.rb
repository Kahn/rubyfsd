require 'concurrent-ruby'
require 'securerandom'
require 'geokit'

require_relative 'request_finder'
require_relative 'response'
require_relative 'request/login_ident'
require_relative 'request/login_auth_atc'
require_relative 'request/atc_update'
require_relative 'request/atc_control'
require_relative 'request/disconnect'
require_relative 'request/fullname'
require_relative 'request/metar'
require_relative 'request/text_message'
require_relative 'request/login_auth_pilot'
require_relative 'request/pilot_update'
require_relative 'request/forward_message_direct'
require_relative 'request/forward_message_ranged'
require_relative 'request/flightplan_file'
require_relative 'request/flightplan_get'
require_relative 'request/flightplan_amend'
require_relative 'request/scratchpad'
require_relative 'request/squawk'

class ConnectionHandler

  def initialize(socket, connected_users, mailboxes, logger, sweatbox)
    @user_data = Concurrent::Hash.new
    @socket = socket
    @connected_users = connected_users
    @mailboxes = mailboxes
    @logger = logger
    @user_data[:sweatbox?] = sweatbox

    @request_finder = RequestFinder.new(@user_data, @connected_users, @logger)
    @user_data[:logged_in] = false
    @user_data[:session_id] = SecureRandom.hex[0..21]
    @user_data[:id_complete?] = false

    @user_data[:location] = [0, 0]
    @user_data[:visibility_range] = 0

    @user_data[:flightplan] = {}
    @user_data[:flightplan][:exists?] = false

    @user_data[:connection_handler] = self
  end

  def start
    @socket.write("$DISERVER:CLIENT:RubyFSD:#{@user_data[:session_id]}\r\n") # Changing "RubyFSD" to the correct vatsim server version string may help solve euroscope connection problems.

    # Main Event Loop
    buffer = ''
    while true
      begin
        socket_data = @socket.read_nonblock(100, {:exception => false})

        # Close the connection if socket_data is nil
        if socket_data.nil?
          process_disconnect
          return
        end

        # Do buffer work
        if socket_data != :wait_readable
          buffer += socket_data
          lines = buffer.split("\r\n", -1)
          buffer = lines.pop

          # Find request lines and process each one by one
          lines.each do |request_line|
            @logger.debug "Total users: #{@connected_users.length}"
            request_line = request_line.strip
            @logger.debug "New line to process: #{@request_finder.find(request_line).inspect} >>> #{request_line}"

            # Get and verify the correct request handler class
            found_request = @request_finder.find(request_line)

            unless found_request
              @logger.warn "Request finder could not find a class name to handle #{request_line}"
              next
            end

            # Looks good. Now to process the request
            request = Object.const_get(found_request).new(request_line, @user_data, @connected_users, @logger)
            response = request.process

            @logger.debug "Successfully processed: #{found_request}"

            # Send Response to client if needed
            if response.should_respond?
              response.lines.each do |line|
                @socket.write(line + "\r\n")
              end
            end

            # Send mail to other users as needed
            if response.should_send_mail?

              response.mail_to_send[:direct].each do |callsign, message|
                unless @mailboxes[callsign].nil?
                  @mailboxes[callsign].push message
                end
              end

              unless response.mail_to_send[:ranged] == []
                send_ranged_messages(response)
              end

              unless response.mail_to_send[:ranged_atc] == []
                send_ranged_messages(response)
              end

              # Push broadcast messages to all users connected
              response.mail_to_send[:broadcast].each do |message|
                @mailboxes.each do |callsign, mailbox|
                  unless callsign == @user_data[:callsign] # Don't want to send mail to our self!
                    mailbox.push message
                  end
                end
              end

              # Disconnect client if needed
              if response.should_kill_connection?
                sleep 1
                process_disconnect
                return
              end
            end
          end
        end

        # Check this user's mailbox and write those messages to the socket
        unless @mailboxes[@user_data[:callsign]].nil?
          @mailboxes[@user_data[:callsign]].each do |line|
            @socket.write line + "\r\n"
          end
          # Reset the mailbox to empty since we've read and sent all the mail to the socket
          @mailboxes[@user_data[:callsign]] = []
        end

        # Give the CPU a break
        sleep 0.1
      rescue Exception => e
        # catch exception and close the connection
        @logger.warn "Exception: " + e.class.name + ': ' + e.message
        @logger.warn "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
        process_disconnect
        return
      end
    end
  end

  def user_data
    @user_data
  end

  def connected_users
    @connected_users
  end

  def mailboxes
    @mailboxes
  end

  # Process ranged requests by measuring the geographical distance between each user connected, in order to decide whether to send the message to them.
  def send_ranged_messages(response)
    sender_location = Geokit::LatLng.normalize(@user_data[:location])
    sender_visibility_range = @user_data[:visibility_range]

    # Truncate through each user, measure distance, and send appropriate message to their mailbox
    # TODO: Refactor for efficiency
    @connected_users.each do |recipient_callsign, connection_handler|
      # Calculate distance between users
      recipient_location = Geokit::LatLng.normalize(connection_handler.user_data[:location])
      recipient_visibility_range = connection_handler.user_data[:visibility_range]
      max_distance_between_users = sender_visibility_range + recipient_visibility_range

      # Check if the users are within visibility range
      if sender_location.distance_to(recipient_location) <= max_distance_between_users
        unless recipient_callsign == @user_data[:callsign] # Don't want to send mail to ourself!

          # Send ranged messages to all users
          response.mail_to_send[:ranged].each do |message|
            @mailboxes[recipient_callsign].push message
          end

          # Only send ranged_atc messages to ATC users
          response.mail_to_send[:ranged_atc].each do |message|
            if connection_handler.user_data[:client_type] == 'atc'
              @mailboxes[recipient_callsign].push message
            end
          end

        end
      end
    end
  end

  def process_disconnect
    @socket.close
    @connected_users.delete(@user_data[:callsign])
    @mailboxes.delete(@user_data[:callsign])
    @logger.info "#{@user_data[:callsign]} disconnected!"

    response = Response.new
    if user_data[:client_type] == 'atc'
      @logger.debug "Sending ATC disconnect to ranged users"
      response.push_mail('ranged', "#DA#{@user_data[:callsign]}:SERVER")
    elsif user_data[:client_type] == 'pilot'
      @logger.debug "Sending pilot disconnect to ranged users"
      response.push_mail('ranged', "#DP#{@user_data[:callsign]}:SERVER")
    else
      # do nothing
    end
    send_ranged_messages(response)
  end
end