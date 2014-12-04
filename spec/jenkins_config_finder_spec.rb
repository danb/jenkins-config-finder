require 'spec_helper'
require 'pp'

describe JenkinsConfigFinder do 
    before do
        stub_request(:any, "http://mock_user:mock_password@www.x.com/api/json").to_return(:body => %q|{ "jobs": [ { "name": "job1", "url": "http://www.x.com/job/job1", "color": "blue" }, { "name": "job2", "url": "http://www.x.com/job/job2", "color": "blue" } ] }|)
        stub_request(:any, "http://mock_user:mock_password@www.x.com/job/job1/config.xml").to_return(:body => %q|<?xml version='1.0' encoding='UTF-8'?>
           <project>
             <description>MY_JOB_1</description>
           </project>|)
        stub_request(:any, "http://mock_user:mock_password@www.x.com/job/job2/config.xml").to_return(:body => %q|<?xml version='1.0' encoding='UTF-8'?>
           <project>
            <description>MY_JOB_2</description>
              <properties>
                <hudson.plugins.promoted__builds.JobPropertyImpl plugin="promoted-builds@2.18">
                  <activeProcessNames>
                    <string>push_test</string>
                  <activeProcessNames>
                </hudson.plugins.promoted__builds.JobPropertyImpl>
                <hudson.plugins.jacoco.JacocoPublisher plugin="jacoco@1.0.16">
                  <minimumMethodCoverage>0</minimumMethodCoverage>
                </hudson.plugins.jacoco.JacocoPublisher>
              </properties></project>|)
        stub_request(:any, "http://mock_user:mock_password@www.x.com/job/job2/promotion/process/push_test/config.xml").to_return(:body => %q|<?xml version='1.0' encoding='UTF-8'?>
            <hudson.plugins.promoted__builds.PromotionProcess plugin="promoted-builds@2.17">
              <disabled>nope</disabled>
              <buildSteps></buildSteps>
            </hudson.plugins.promoted__builds.PromotionProcess>|)
    end

    describe "Connect" do
       it "connects to jenkins" do
          expect(
            lambda do 
              JenkinsConfigFinder.connect('http://www.x.com', 'mock_user', 'mock_password')
            end
          ).not_to raise_error
        end

        it "searches jenkins" do
            JenkinsConfigFinder.connect('http://www.x.com', 'mock_user', 'mock_password')
            conf = JenkinsConfigFinder.find("//project//description")
            conf.should include('job1' => 'MY_JOB_1')
        end

        it "searches jenkins with a node" do
            JenkinsConfigFinder.connect('http://www.x.com', 'mock_user', 'mock_password')
            conf = JenkinsConfigFinder.find("//hudson.plugins.jacoco.JacocoPublisher", "minimumMethodCoverage")
            conf.should include('job2' => '0')
        end

        it "searches a promotion job" do
            JenkinsConfigFinder.connect('http://www.x.com', 'mock_user', 'mock_password')
            conf = JenkinsConfigFinder.find("//disabled")
            conf.should include('job2/push_test' => 'nope')
        end

        it "searches a promotion job for a node" do
            JenkinsConfigFinder.connect('http://www.x.com', 'mock_user', 'mock_password')
            conf = JenkinsConfigFinder.find("//hudson.plugins.promoted__builds.PromotionProcess", "disabled")
            conf.should include('job2/push_test' => 'nope')
        end

        it "searches for something not found" do
            JenkinsConfigFinder.connect('http://www.x.com', 'mock_user', 'mock_password')
            conf = JenkinsConfigFinder.find("//monkeys")
            expect(conf).to be_empty
        end

    end
    
end