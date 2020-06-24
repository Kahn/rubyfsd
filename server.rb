#!/usr/bin/env ruby

require 'socket'
require 'thread'
require 'concurrent-ruby'
require 'logging'

require_relative 'lib/connection_handler'

class Server

  def initialize
    @logger = Logging.logger(STDOUT)

    # ** Comment this for verbose logging **
    @logger.level = Logger::INFO
  end

  def start
    @connected_users = Concurrent::Hash.new
    @mailboxes = Concurrent::Hash.new
    @logger.info "Listening for connections..."

    # Normal FSD connections
    Thread.new {
      Socket.tcp_server_loop(6820) { |socket, client_addrinfo|
        Thread.new {
          begin
            @logger.info "Sweatbox trainer client connected from: #{client_addrinfo.ip_address}:#{client_addrinfo.ip_port}"
            connection_handler = ConnectionHandler.new(socket, @connected_users, @mailboxes, @logger, true)
            connection_handler.start
          rescue Exception => e
            @logger.warn "Exception: " + e.class.name + ': ' + e.message
            @logger.warn "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
          end
        }
      }
    }

    # Sweatbox trainer connections
    Socket.tcp_server_loop(6809) { |socket, client_addrinfo|
      Thread.new {
        begin
          @logger.info "Normal user client connected from: #{client_addrinfo.ip_address}:#{client_addrinfo.ip_port}"
          connection_handler = ConnectionHandler.new(socket, @connected_users, @mailboxes, @logger, false)
          connection_handler.start
        rescue Exception => e
          @logger.warn "Exception: " + e.class.name + ': ' + e.message
          @logger.warn "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
        end
      }
    }


  end
end

x = Server.new
x.start