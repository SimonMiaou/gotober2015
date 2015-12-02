#!/usr/bin/env ruby
# encoding: utf-8

# Docker run command:
#   docker run --name='workshop_need' -it -v /c/Users/fred/src/microservice_workshop/ruby:/workshop -w /workshop/rental_offer fredgeorge/ruby_microservice:latest bash
# To run monitor at prompt:
#   ruby rental_car_need.rb 192.168.59.103 bugs

require_relative 'rental_offer_need_packet'
require_relative 'connection'

# Expresses a need for rental car offers
class RentalOfferSolution

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
      if payload['solutions'].empty?
        puts " [x] Published a rental offer solution on the bus"
        offer = RentalOfferNeedPacket.new
        offer.propose_solution(
          {
            'type' => 'super-car',
            'model' => 'Batmobile'
          }
        )
        exchange.publish offer.to_json
      end
    end
  end

end

RentalOfferSolution.new(ARGV.shift, ARGV.shift).start
