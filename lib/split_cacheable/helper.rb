module Split
    module Cacheable
        module Helper
            def self.included(base)
                base.send :include, InstanceMethods
                base.extend ClassMethods
            end

            module InstanceMethods
                def fragment_cache_key(key)
                    super("#{current_tests_and_variations}/#{key}")
                end

                def current_tests_and_variations
                    Split::Cacheable::Adapter.new(self, self.action_name.to_sym).get_current_variations
                end
            end

            module ClassMethods
                def cacheable_ab_test(test_name, options)
                    options[:except] = Array(options[:except])
                    options[:only] = Array(options[:only])

                    self.split_cacheable_ab_tests << options.merge({:test_name => test_name})
                end

                def split_cacheable_ab_tests
                    @split_cacheable_ab_tests ||= Array.new
                end
            end
        end
    end
end