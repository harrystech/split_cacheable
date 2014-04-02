module Split
    module Cacheable
        module Helper
            def self.included(base)
                base.send :include, InstanceMethods
                base.extend ClassMethods
            end

            module InstanceMethods
                # Override the default ActionController::Base action_cache key creation
                # by injecting 
                def fragment_cache_key(key)
                    super("#{current_tests_and_variations}/#{key}")
                end

                # Controller helper method to get the current active tests + variations in the form of a cache_key
                def current_tests_and_variations
                    Split::Cacheable::Adapter.new(self, self.action_name.to_sym).get_current_variations
                end
            end

            module ClassMethods
                # This is how you specify your tests in the sub-class of ActionController::Base
                # ex: cacheable_ab_test :homepage_hero, :only => :our_story, :if => Rails.env.production?
                def cacheable_ab_test(test_name, options)
                    options[:except] = Array(options[:except])
                    options[:only] = Array(options[:only])

                    self.split_cacheable_ab_tests << options.merge({:test_name => test_name})
                end

                # Class level variable. cacheable_ab_test's get pushed onto it
                def split_cacheable_ab_tests
                    @split_cacheable_ab_tests ||= Array.new
                end
            end
        end
    end
end