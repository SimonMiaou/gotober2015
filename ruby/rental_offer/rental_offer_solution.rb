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
    @answered_ids = []
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
      if !@answered_ids.include?(payload['id'])
        puts " [x] Published a rental offer solution on the bus"
        payload
        payload['solutions'] << random_car
        payload['solutions'] << random_car if Random.rand(10) == 0
        exchange.publish payload.to_json
        @answered_ids << payload['id']
      end
    end
  end

  def random_car
    cars = [
      {
        'type' => 'super-car',
        'modal' => 'Batmobile',
        'price-per-day' => 1_000
      },
      {
        'type' => 'truck',
        'modal' => 'Fire truck',
        'price-per-day' => 500
      },
      {
        'type' => 'car',
        'modal' => 'Ford Fiesta',
        'price-per-day' => 100
      }
    ]

    cars[Random.rand(cars.size)]
  end

end

RentalOfferSolution.new(ARGV.shift, ARGV.shift).start
