#!/usr/bin/env ruby
# encoding: utf-8

# Docker run command:
#   docker run --name='workshop_need' -it -v /c/Users/fred/src/microservice_workshop/ruby:/workshop -w /workshop/rental_offer fredgeorge/ruby_microservice:latest bash
# To run monitor at prompt:
#   ruby rental_car_need.rb 192.168.59.103 bugs

require_relative 'connection'
require 'json'

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
    puts " [*] Waiting for need on the bus... To exit press CTRL+C"
    queue.subscribe(block: true) do |delivery_info, properties, body|
      payload = JSON.parse(body)
      car = random_car

      if !payload['solutions'].include?(car)

        puts " [x] Published a rental offer solution on the bus"
        payload['solutions'] << random_car
        exchange.publish payload.to_json
      end
    end
  end

  def random_car
    cars = [
      {
        'type' => 'super-car',
        'model' => 'Batmobile',
        'price_per_day' => 1_000
      },
      {
        'type' => 'truck',
        'model' => 'Fire truck',
        'price_per_day' => 500
      },
      {
        'type' => 'car',
        'model' => 'Ford Fiesta',
        'price_per_day' => 100
      }
    ]

    cars[Random.rand(cars.size)]
  end

end

RentalOfferSolution.new(ARGV.shift, ARGV.shift).start
