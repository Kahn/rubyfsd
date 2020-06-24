class RequestFinder

  def initialize(user_data, connected_users, logger)
    @user_data = user_data
    @connected_users = connected_users
    @logger = logger
  end

  def find(raw_line)
    if raw_line.start_with? '%'
      return 'RequestATCUpdate'
    end

    if raw_line.start_with? '@'
      return 'RequestPilotUpdate'
    end

    if raw_line.start_with? '$CQ'
      cq_type = raw_line.split(':')[2]
      class_name = case(cq_type)
                   when 'ATC'
                     'RequestATCControl'
                   when 'RN'
                     'RequestFullName'
                   when 'ACC', 'WH'
                     if raw_line.split(':')[1] == '@94836' || raw_line.split(':')[1] == '@94835'# General broadcast with a/c information
                       'RequestForwardMessageRanged'
                     else # if it's not that it's going direct to someone else
                       'RequestForwardMessageDirect'
                     end
                   when 'ATIS', 'SV', 'CAPS'
                     'RequestForwardMessageDirect'
                   when 'FP'
                     'RequestFlightplanGet'
                   when 'SC'
                     'RequestScratchpadAmend'
                   when 'BC'
                     'RequestSquawkAmend'
                   else
                     false
                   end
      return class_name
    end

    class_name = case(raw_line[0..2])
                 when '$ID'
                   'RequestLoginIdent'
                 when '#AA'
                   'RequestLoginAuthATC'
                 when '#AP'
                   'RequestLoginAuthPilot'
                 when '#DA', '#DP'
                   'RequestDisconnect'
                 when '$AX'
                   'RequestMETAR'
                 when '#TM'
                   'RequestTextMessage'
                 when '#SB', '$CR', '#PC'
                   'RequestForwardMessageDirect'
                 when '$FP'
                   'RequestFlightplanFile'
                 when '$AM'
                   'RequestFlightplanAmend'
                 else
                   false
                 end
    return class_name
  end

end