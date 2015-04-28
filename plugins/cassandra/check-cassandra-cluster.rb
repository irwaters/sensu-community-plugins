#!/usr/bin/env ruby
##
#  little plugin that will check the status of a cassandra cluster
#  really only cares about nodes being up and down.  
#  all of this stuff is exposed via jmx, so we are going to call nodetool 
#  since you really kinda need to have it or the underlying jar files...
##

require 'sensu-plugin/check/cli'

class CheckNodeCluster < Sensu::Plugin::Check::CLI
    check_name "check node cluster"

    option :seed,
        description: "a db seed to connect to",
        short: "-s seed",
        long: "--seed seed",
        required: true

    option :nodetool,
        description: "where is nodetool?",
        short: "-s path",
        long: "--nodetool path",
        required: false,
        default: "/usr/bin/nodetool"
    


    def run
        config[:nodetool] ? @nodetool = config[:nodetool].to_s : @nodetool = "/usr/bin/nodetool"
        unknown("nodetool doesn't exist") if !File.exists?(@nodetool)
        `#{@nodetool} -h #{config[:seed].to_s}`


        ok("it's all good man")
    end



end

