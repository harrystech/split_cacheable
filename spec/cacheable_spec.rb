require 'spec_helper'

describe Split::Cacheable do
    ALL_VARIATIONS = [Split::Cacheable::Adapter::DEFAULT_KEY, "test_1/old/test_2/left", "test_1/old/test_2/right", "test_1/new/test_2/left", "test_1/new/test_2/right"]

    it "should return the default variation if there is no request" do
        expect(Split::Cacheable::Adapter.new(TestControllerWithoutRequest.new, :index).get_current_variations).to eql Split::Cacheable::Adapter::DEFAULT_KEY
    end

    it "should return a possible active variation if the controller has a request" do
        expect(ALL_VARIATIONS).to include(Split::Cacheable::Adapter.new(TestControllerWithRequest.new, :index).get_current_variations)
    end

    it "should return all active tests for a controller/action combination" do
        expect(Split::Cacheable::Adapter.new(TestControllerWithRequest.new, :index).active_tests).to eql [{:only=>[:index], :except=>[], :test_name=>:test_1}, {:only=>[], :except=>[:show], :test_name=>:test_2}]
    end

    it "should disregard tests that don't pass the :if Proc" do
        controller = TestControllerWithRequestAndProc.new
        expect(Split::Cacheable::Adapter.new(controller, :index).get_current_variations).to eql Split::Cacheable::Adapter::DEFAULT_KEY

        controller.instance_variable_set("@mobile_device", true)
        expect(ALL_VARIATIONS).to include(Split::Cacheable::Adapter.new(TestControllerWithRequest.new, :index).get_current_variations)
    end

    describe "get_all_possible_variations method" do
        it "should return all possible variations of the cachekey" do
            expect(Split::Cacheable::Adapter.new(TestControllerWithoutRequest.new, :index).get_all_possible_variations).to eql ALL_VARIATIONS
        end

        it "should return the default key when there are no variations" do
            expect(Split::Cacheable::Adapter.new(TestControllerWithNoVariations.new, :index).get_all_possible_variations).to eql [Split::Cacheable::Adapter::DEFAULT_KEY]
        end

        it "should return one test plus the default key when there is one test" do
            expect(Split::Cacheable::Adapter.new(TestControllerWithOneVariation.new, :index).get_all_possible_variations).to eql [Split::Cacheable::Adapter::DEFAULT_KEY, "test_1/old", "test_1/new"]
        end
    end
end