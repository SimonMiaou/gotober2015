require_relative 'connection'
require 'json'

class RentalMembership

  def initialize(host, port)
    @host = host
    @port = port
    @members = ['Fred', 'George']
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
      if json['username']
        ratio = @members.include?(json['username']) ? 0.9 : 0.8
        offer_type = @members.include?(json['username']) ? 'membership' : 'new_membership'

        solutions_to_update = json['solutions'].reject { |s| s['deal_type'] }

        if solutions_to_update.size > 0
          json['solutions'] = solutions_to_update.map do |solution|
            solution['deal_type'] = offer_type
            solution['price_per_day'] = (solution['price_per_day'] * ratio).to_i
            solution
          end

          exchange.publish json.to_json
        end
      end
    end
  end

end

RentalMembership.new(ARGV.shift, ARGV.shift).start
