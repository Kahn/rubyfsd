class Response

  def self.empty
    Response.new
  end

  def initialize
    @lines = []
    @mail_to_send = {
        direct: {},
        ranged: [],
        ranged_atc: [],
        broadcast: []
    }
    @kill_connection = false
  end

  def should_respond?
    !@lines.empty?
  end

  def should_kill_connection?
    @kill_connection
  end

  def kill_connection
    @kill_connection = true
  end

  def should_send_mail?
    !@mail_to_send.empty?
  end

  def lines
    @lines
  end

  def mail_to_send
    @mail_to_send
  end

  def push(line)
    @lines.push line.chomp
  end

  # args[0] = 'direct', 'ranged', 'ranged_atc' or 'broadcast'
  # args[1] = line to send
  # args[2] = callsign of 'direct' receiver
  def push_mail(*args)
    args[1] = args[1].strip
    case args[0]
    when 'direct'
      @mail_to_send[:direct][args[2]] = args[1]
    when 'ranged'
      @mail_to_send[:ranged].push args[1]
    when 'ranged_atc'
      @mail_to_send[:ranged_atc].push args[1]
    when 'broadcast'
      @mail_to_send[:broadcast].push args[1]
    end
  end

end