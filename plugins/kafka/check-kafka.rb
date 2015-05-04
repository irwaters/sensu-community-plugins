#!/usr/bin/env ruby

require 'poseidon'
require 'sensu-plugin/check/cli'

class CheckKafka < Sensu::Plugin::Check::CLI
    
    attr_accessor :producer, :consumer

    check_name "check kafka"
    
    option :host,
        description: "host to connect to",
        short: "-h",
        long: "--host host",
        required: true

    option :port,
        description: "port to connect to",
        short: "-p",
        long: "--port port",
        default: 9092,
        required: false



    def consumer(host=nil, port=nil)
        consumer = Poseidon::PartitionConsumer.new("kafka_monitor", 
                                                   config[:host].to_s,
                                                   config[:port].to_i,
                                                   "sensu_check2", 
                                                   0, 
                                                   :earliest_offset)
    end
    def producer(host=nil, port=nil)
        producer = Poseidon::Producer.new( ["#{config[:host]}:#{config[:port]}"] , "kafka_monitor", :type => :sync)
    end

    def message_count()   
        begin
            consumer.fetch.count()
        rescue Poseidon::Errors::UnknownTopicOrPartition => e
            publish()
            return(1)
        rescue => e
            critical("Could not consume messages #{e.inspect}")
        end
    end

    def publish
        messages = []
        messages << Poseidon::MessageToSend.new("sensu_check2", "barbar")
        begin
            producer.send_messages(messages)
        rescue => e
            critical("Could not publish messages #{e.inspect}")
        end
    end



    def run
        message_count = message_count()
        if message_count > 25
            ok "count is #{message_count}"
        else
            publish
            message_count = message_count()
            ok "count is now #{message_count}"
        end
    end
        
end

