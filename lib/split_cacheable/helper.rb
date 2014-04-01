module Split
    module Cacheable
        module Helper
            @@ab_tests = Array.new

            def current_tests_and_variations
                Split::Cacheable.new(self, self.action_name.to_sym).get_current_variation
            end

            def self.enable_ab_test(test_name, options)
                options[:except] = Array(options[:except])
                options[:only] = Array(options[:only])

                @@ab_tests << options.merge({:test_name => test_name})
            end

            def self.ab_tests
                @@ab_tests
            end
        end
    end
end