require "split_cacheable/version"
require 'split_cacheable/helper'
require 'split_cacheable/engine' if defined?(Rails) && Rails::VERSION::MAJOR === 3
require 'split'

# This is the main Adapter instance. It expects:
#     controller_instance => An instance of ActionController::Base
#     action_name => The current action being performed (as a symbol)
#
# We don't include this as a module so that you can instantite this yourself
# so you can call get_all_possible_variations to clear your caches

module Split
    module Cacheable
        class Adapter
            DEFAULT_KEY = 'default/control'

            def initialize(controller_instance, action_name)
                @controller = controller_instance
                @action_name = action_name
            end

            # Get all tests which should be active on this controller for this action
            def active_tests
                ab_tests = @controller.class.split_cacheable_ab_tests.select { |test_obj|
                    is_active = false

                    if test_obj[:only].include?(@action_name)
                        is_active = true
                    end

                    if !test_obj[:only] && test_obj[:except].exclude?(@action_name)
                        is_active = true
                    end

                    # The assumption here is that we should only evaluate the :if Proc or Boolean
                    # if we are part of a live ActionController::Base.
                    # This allows active_tests to return all possible active tests for when you call get_all_possible_variations
                    if @controller.request && test_obj[:if]
                        if is_active && (test_obj[:if].is_a?(Proc) ? test_obj[:if].call(@controller) : !!test_obj[:if])
                            is_active = true
                        else
                            is_active = false
                        end
                    end

                    is_active
                }
            end

            # Use Split to return a partial cache key (used in fragment_cache_key)
            # by calling ab_test which is an internal Split::Helper method that is now on your
            # controller instance
            #
            # You should not be calling this method outside of a live ActionController::Base
            def get_current_variations
                if !@controller.request
                    return DEFAULT_KEY
                else
                    return !active_tests.empty? ? active_tests.map{|test_obj| "#{test_obj[:test_name]}/#{@controller.ab_test(test_obj[:test_name])}"}.join('/') : DEFAULT_KEY
                end
            end

            # Search the Split::ExperimentCatalog to find all tests and generate
            # every possible partial cache key
            #
            # Use this to clear all your action_caches
            def get_all_possible_variations
                test_variations = Array.new
                active_tests.each { |test_obj|  
                    split_test = Split::ExperimentCatalog.find(test_obj[:test_name])
                    if split_test
                        test_variations << split_test.alternatives.map { |alternative|
                            "#{split_test.name}/#{alternative.name}"
                        } 
                    end
                }

                case test_variations.length
                when 0
                    return []
                when 1
                    return test_variations[0]
                else
                    first_test = test_variations.shift
                    return first_test.product(*test_variations).map{|a| a.join("/")}
                end
            end
        end
    end
end