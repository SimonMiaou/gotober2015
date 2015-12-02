Rapids, Rivers and Pounds

0MQ?

Kafka => Rapids
0MQ => River

Always publish on rapids => Somebody may need it

We encourage more than one version in a time for a microservice.
Metrics on version? "This version have better performance than this one"

"There is a lot of messages and I don't care"

# Coding

## Server and monitoring

### with docker
```
docker run -d -e RABBITMQ_NODENAME=microservice_rabbitmq -p 15672:15672 -p 5672:5672 --name rabbitmq rabbitmq:management

ruby rental_offer/rental_offer_monitor.rb 192.168.99.100 5672
ruby rental_offer/rental_offer_need.rb 192.168.99.100 5672
```

### on private network
```
ruby rental_offer/rental_offer_monitor.rb 10.0.0.2 5678
ruby rental_offer/rental_offer_need.rb 10.0.0.2 5678
```


# Back to talk

No need for unit testing
Feature testing by KPI

Have to edit a service in a langage you don't mastering? Rewrite it

Reuse the same paket when answering it
Maybe there is data you don't care but others will

# Back from lunch

(TODO: check xchange conf in berlin)

Pair programming may be the solution to too rich documentation?
Don't need to document payload, we know it !

No need for different channel
-> Who need the message? We don't know, so spread it !
-> Easy to debug, just take the bus and replay it on your laptop

Don't manage concurency, only one consumer if there is concurency issues (not sur to followed everything here)
