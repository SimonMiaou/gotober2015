require_relative 'connection'
require 'json'

class RentalOfferBestSolution

  def initialize(host, port)
    @host = host
    @port = port
  end

  def start
    Connection.with_open(@host, @port) {|ch, ex| suggest_solution(ch, ex) }
  end

  private

  def suggest_solution(channel, exchange)
    queue = channel.queue("", :exclusive => true)
    queue.bind exchange
    puts " [*] Waiting for solutions on the bus... To exit press CTRL+C"
    queue.subscribe(block: true) do |delivery_info, properties, body|
      payload = JSON.parse(body)
      next if payload['best_solution']

      (payload['solutions'] || []).each do |solution|
        next unless solution['price-per-day']

        if @best_solution.nil? || solution['price-per-day'].to_i < @best_solution['price-per-day'].to_i
          @best_solution = solution
          puts " [+] Emit best solution: #{@best_solution}"

          payload['best_solution'] = @best_solution
          exchange.publish solution.to_json
        end
      end
    end
  end

end

RentalOfferBestSolution.new(ARGV.shift, ARGV.shift).start
