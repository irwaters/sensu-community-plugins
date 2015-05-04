#!/usr/bin/env ruby

require 'poseidon'
require 'sensu-plugin/check/cli'

class CheckKafka < Sensu::Plugin::Check::CLI
    end
    
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
        default: 9092,
        required: false



    def message_count()   
        begin
        consumer.fetch.count()
        rescue Poseidon::Errors::UnknownTopicOrPartition => e
            self.publish()
            return(1)
        end
    end

    def consumer
        consumer = Poseidon::PartitionConsumer.new("kafka_monitor", 
                                                   config[:host].to_s,
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

