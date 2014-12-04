#!/usr/bin/env ruby

require 'optparse'
require 'jenkins_config_finder'

options = {}

optparse = OptionParser.new do |opts|
    opts.banner = "Usage: jenkins-config-finder [options]"

    opts.on("-u", "--username USERNAME", "Username") do |user|
        options[:user] = user
    end
    opts.on("-p", "--password PASSWORD", "Password") do |password|
        options[:password] = password
    end
    opts.on("-s", "--server URL", "URL of the Jenkins server") do |url|
        options[:url] = url
    end
    opts.on("-x", "--xml-path PATH", "XML Path to search for i.e. //project//description") do |path|
        options[:path] = path
    end
    opts.on("-n", "--node NODE", "NODE to print i.e. name") do |node|
        options[:node] = node
    end
end

begin
    optparse.parse!
    mandatory = [:url, :user, :password, :path]
    missing = mandatory.select{ |param| options[param].nil? }     
    if not missing.empty?                                            
      puts "Missing options: #{missing.join(', ')}"                  
      puts optparse                                                  
      exit                                                           
    end                                                              
rescue OptionParser::InvalidOption, OptionParser::MissingArgument      
  puts $!.to_s                                                          
  puts optparse                                                         
  exit                                                                  
end                                                                     

JenkinsConfigFinder.connect(options[:url], options[:user], options[:password])
jenkins_config = JenkinsConfigFinder.find(options[:path], options[:node])

jenkins_config.each do |key, value| 
  puts "::::::::#{key}::::::::"
  puts value
end