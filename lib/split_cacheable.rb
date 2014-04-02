require "split_cacheable/version"
require 'split_cacheable/helper'
require 'split_cacheable/engine' if defined?(Rails) && Rails::VERSION::MAJOR === 3
require 'split'

module Split
    module Cacheable
        class Adapter
            DEFAULT_KEY = 'default/control'

            def initialize(controller_instance, action_name)
                @controller = controller_instance
                @action_name = action_name
            end

            def active_tests
                ab_tests = @controller.class.split_cacheable_ab_tests.select { |test_obj|
                    is_active = false

                    if test_obj[:only].include?(@action_name)
                        is_active = true
                    end

                    if !test_obj[:only] && test_obj[:except].exclude?(@action_name)
                        is_active = true
                    end

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

            def get_current_variations
                if !@controller.request
                    return DEFAULT_KEY
                else
                    return !active_tests.empty? ? active_tests.map{|test_obj| "#{test_obj[:test_name]}/#{@controller.ab_test(test_obj[:test_name])}"}.join('/') : DEFAULT_KEY
                end
            end

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