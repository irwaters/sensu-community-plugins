#!/usr/bin/env ruby

require 'json'
require 'sensu-plugin/check/cli'

class CheckPM2 < Sensu::Plugin::Check::CLI

    check_name "pm2 checker"

    option :warn,
        description: 'warning threshold',
        short: "-w count",
        long: "--warn count",
        required: false

    option :crit,
        description: 'crit threshold',
        short: "-c count",
        long: "--crit count",
        required: true

    option :user,
        description: "user who's running pm2",
        short: "-u user",
        long: "--user user",
        required: true
		

    def run
        total_restarts = 0

        @warn=config[:warn].to_i
        @crit=config[:crit].to_i
        @user=config[:user].to_s

        out = %x{sudo su - @user -c "/usr/local/bin/pm2 jlist"}



        begin
	        jout = JSON.parse(out) 
        rescue => e
	        unknown( "failed to parse json" )
        end

        jout.each { |app|
	        if (app["pm2_env"]["status"] != "online")
		        unknown ( "Node isn't running" )
	        end
	        total_restarts += app["pm2_env"]["restart_time"].to_i
        }


        ok  "total restarts: #{total_restarts}"  if total_restarts.to_i < @warn.to_i
        warning  "total restarts: #{total_restarts}"  if total_restarts >= @warn && total_restarts < @crit
        critical  "total restarts: #{total_restarts}"  if total_restarts >= @crit
        unknown "no idea what happened"
    end

end

