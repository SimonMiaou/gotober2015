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
