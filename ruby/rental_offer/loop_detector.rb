require_relative 'connection'
require 'json'

class LoopDetector

  def initialize(host, port)
    @host = host
    @port = port
  end

  def start
    Connection.with_open(@host, @port) {|ch, ex| monitor_solutions(ch, ex) }
  end

  private

  def monitor_solutions(channel, exchange)
    queue = channel.queue("", :exclusive => true)
    queue.bind exchange
    puts " [*] Waiting for solutions on the bus... To exit press CTRL+C"
    queue.subscribe(block: true) do |delivery_info, properties, body|
      json = JSON.parse(body)
      if json['breadcrumbs'].nil?
        puts 'I didn\'t find a breadcrumbs'
      elsif json['breadcrumbs'].size > 9
        puts "There is a loop: #{json['breadcrumbs'].join(' / ')}"
      else
        puts "Cool (#{json['breadcrumbs'].size})"
      end
    end
  end

end

LoopDetector.new(ARGV.shift, ARGV.shift).start
