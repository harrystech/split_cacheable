module Split
    module Cacheable
        class Engine < ::Rails::Engine
            initializer "split" do |app|
                if Split.configuration.include_rails_helper
                    ActionController::Base.send :include, Split::Cacheable::Helper
                    ActionController::Base.helper Split::Cacheable::Helper
                end
            end
        end
    end
end