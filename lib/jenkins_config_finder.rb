
require 'jenkins_api_client'
require 'nokogiri'



module JenkinsConfigFinder

  # Establishes a connection to the jenkins server
  #
  # ==== Attributes
  # * +url+ A URL for a jenkins server
  # * +user+ The username for jenkins
  # * +password+ The password for the user
  def self.connect(url, user, password)
    @client = JenkinsApi::Client.new(:server_url => url,
         :username => user, 
         :password => password,
         :log_location => '/dev/null')

  end

  # Searches all jobs in the jenkins server looking for the supplied path
  #
  # ==== Attributes
  #
  # * +path+ An xpath node to search for
  # * +node+ Returns a node matched under the path (Optional)
  #
  # ==== Examples
  #
  #   # Find and return all projects descriptions
  #   JenkinsConfigFinder.find('project//description')
  #   # Find and return all git repositories urls
  #   JenkinsConfigFinder.find('@class:hudson.plugins.git.GitSCM', //hudson.plugins.git.UserRemoteConfig//url)
  #
  # ==== Returns
  #
  # * a hash of all the matching jenkins jobs as keys, and the value being the matched config
  def self.find(path, node = nil)

      jenkins_config = {}
      jobs =  @client.job.list(".*")

      job = JenkinsApi::Client::Job.new(@client)
      jobs.each do |j|
        config =  job.get_config(j)
        config_obj = Nokogiri::XML(config)    
        if node.nil? 
          if config_obj.root.at_xpath(path)
            jenkins_config[j] = config_obj.root.at_xpath("#{path}").content.to_s 
          end
        else 
          if config_obj.root.at_xpath("#{path}//#{node}")
            jenkins_config[j] = config_obj.root.at_xpath("#{path}//#{node}").content.to_s 
          end
        end
        if config_obj.root.at_xpath("//project//properties//hudson.plugins.promoted__builds.JobPropertyImpl")
          promotion_name = config_obj.root.at_xpath("//project//properties//hudson.plugins.promoted__builds.JobPropertyImpl//activeProcessNames//string").content
          begin
            promotion_config = job.get_config("#{j}/promotion/process/#{promotion_name}")
          rescue JenkinsApi::Exceptions::NotFound
            promotion_config = nil
          end

          unless promotion_config.nil?
            promotion_obj = Nokogiri::XML(promotion_config) 
            if node.nil? then
              if promotion_obj.root.at_xpath(path)
                jenkins_config["#{j}/#{promotion_name}"] = promotion_obj.root.at_xpath("#{path}").content.to_s 
              end
            elsif promotion_obj.root.at_xpath("#{path}//#{node}")
              jenkins_config["#{j}/#{promotion_name}"] = promotion_obj.root.at_xpath("#{path}//#{node}").content.to_s 
            end
          end
        end
      end

      return jenkins_config
    end
end