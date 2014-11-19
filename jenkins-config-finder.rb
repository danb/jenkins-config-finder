#!/usr/bin/env ruby

require 'jenkins_api_client'
require 'nokogiri'
require 'optparse'


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

@client = JenkinsApi::Client.new(:server_url => options[:url],
         :username => options[:user], 
         :password => options[:password],
         :log_location => '/dev/null')

list =  @client.job.list(".*")

job = JenkinsApi::Client::Job.new(@client)
list.each do |j|
    config =  job.get_config(j)
    config_obj = Nokogiri::XML(config)    
    if options[:node].nil? then
      if config_obj.root.at_xpath(options[:path])
        puts "::::#{j}:::::"
        puts config_obj.root.at_xpath("#{options[:path]}").to_s 
      end
    else
      if config_obj.root.at_xpath("#{options[:path]}//#{options[:node]}")
        puts "::::#{j}:::::"
        puts config_obj.root.at_xpath("#{options[:path]}//#{options[:node]}").to_s 
      end
    end
end
