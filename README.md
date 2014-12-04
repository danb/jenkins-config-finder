# Jenkins Config Finder [![Build Status](https://travis-ci.org/danb/jenkins-config-finder.svg?branch=master)](https://travis-ci.org/danb/jenkins-config-finder)

Searches all the jobs and promotions on a jenkins server to find a supplied XPath pattern.

## Installation 

Installation should be as simple as the following.

```
$ gem install jenkins-config-finder
```

## Usage 

### Command Line
   
You can search a jenkins server from the command line.  
Example: list all the job descriptions
```
$ jenkins-config-finder.rb 
Missing options: url, user, password, path
Usage: jenkins-config-finder [options]
    -u, --username USERNAME          Username
    -p, --password PASSWORD          Password
    -s, --server URL                 URL of the Jenkins server
    -x, --xml-path PATH              XML Path to search for i.e. //project//description
    -n, --node NODE                  NODE to print i.e. name
$ jenkins-config-finder.rb -s http://my-jenkins-server.com -u dan -p password123 -x //description 
::::::::MyProject::::::::
MyProject delivers the functionality that is required
::::::::YourProject::::::::
YourProject aims to simplify your life
```

### Ruby

You can integrate the searches into ruby code by searching with an XPath path.

Example: list all the jobs git urls
```
require 'jenkins_config_finder'

JenkinsConfigFinder.connect(server, username, password)
jenkins_config = JenkinsConfigFinder.find('//scm[@class="hudson.plugins.git.GitSCM"]', url)
jenkins_config.each do |job, url|
   puts "#{job} // #{url}"
end
```

## Creators

**Dan Bradley**
- <https://github.com/danb>
- <https://twitter.com/webdanb>

