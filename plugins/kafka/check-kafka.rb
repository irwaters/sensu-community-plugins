#!/usr/bin/env ruby

require 'poseidon'
require 'sensu-plugin/check/cli'

class CheckKafka < Sensu::Plugin::Check::CLI
    
    check_name "check kafka"
    
    option :host,
        description: "host to connect to",
        short: "-h",
        long: "--host",
        required: true

    option :port,
        description: "port to connect to",
        short: "-p",
        long: "--port",
        required: true


    def message_count()   
        consumer.fetch.count()
    end

    def consumer
        consumer = Poseidon::PartitionConsumer.new("kafka_monitor", 
                                                   config[:host],
                                                   config[:port].to_i,
                                                   "sensu_check", 
                                                   0, 
                                                   :earliest_offset)
    end

    def producer
        producer = Poseidon::Producer.new( ["#{config[:host]}:#{config[:port]}"] , "kafka_monitor", :type => :sync)
    end

    def publish
        messages = []
        messages << Poseidon::MessageToSend.new("sensu_check", "bar")
        producer.send_messages(messages)
    end



    def run
        check = CheckKafka.new()
        message_count = check.message_count
        if message_count > 25
            ok "count is #{message_count}"
        else
            check.publish
            ok "count is now #{check.message_count}"
        end
    end
        
end
