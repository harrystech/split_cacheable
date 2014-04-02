ENV['RACK_ENV'] = "test"

require 'rubygems'
require 'bundler/setup'
require 'split'
require 'ostruct'
require 'split/helper'
require 'split_cacheable'
require 'split_cacheable/helper'

Split.configure do |config|
    config.enabled = true
    config.db_failover = true
    config.persistence = :session
    config.experiments = {
        "test_1" => {
            :alternatives => ['old', 'new']
        },

        "test_2" => {
            :alternatives => ['left', 'right']
        },
    }
end

class TestControllerWithoutRequest
    include Split::Helper
    include Split::Cacheable::Helper

    cacheable_ab_test :test_1, :only => :index
    cacheable_ab_test :test_2, :except => :show
    def index
            
    end

    def session
      @session ||= {}
    end

    def params
      @params ||= {}
    end
end

class TestControllerWithRequest < TestControllerWithoutRequest
    cacheable_ab_test :test_1, :only => :index
    cacheable_ab_test :test_2, :except => :show
    def index
        
    end

    def request(ua = 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_6; de-de) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27')
      r = OpenStruct.new
      r.user_agent = ua
      r.ip = '192.168.1.1'
      @request ||= r
    end
end

class TestControllerWithRequestAndProc < TestControllerWithRequest
    cacheable_ab_test :test_1, :only => :index, :if => Proc.new { |c| c.mobile_device? }
    cacheable_ab_test :test_2, :except => :show, :if => Proc.new { |c| c.mobile_device? }
    
    def index
        
    end

    def mobile_device?
        @is_mobile
    end
end