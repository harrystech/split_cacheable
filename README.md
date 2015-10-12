# Split::Cacheable

An extension to [Split](http://github.com/andrew/split) to allow for automatic cache bucket creation accross Split tests.

## Requirements

The split gem and its dependencies.

## Setup

In your Gemfile:

    gem 'split_cacheable'

Then run:

    bundle install

### Rails 4

Because this gem uses action caching, a feature removed from Rails 4, you will also need to include the `actionpack-action_caching` gem in your Gemfile:

    gem 'actionpack-action_caching'

Then run:

    bundle install

## Why?

We use action caching in Rails 3 to cache both our standard and mobile site. We wanted to be able to quickly run Split tests without worrying about setting a custom cache_path each time as well as remembering to make the needed changes to our ActiveRecord models.

## How?

Under the hood, action caching uses `fragment_cache_key` in `ActionController::Base`. This gem patches this method to incldue our generated current tests and variations.

If you already override `fragment_cache_key` in your project you can get the split partial cache key we generate by calling `current_tests_and_variations`

## Controller DSL

We've created an easy to remember DSL for adding active tests to specific methods:

```
class ProductController < ApplicationController
    cacheable_ab_test :login_flow,
        :only => [:index, :some_other_method],
        :except => [:index, :some_other_method],
        :if => Proc.new { |controller| controller.mobile_device? }

    def index

    end
end
```

* `:login_flow`: The name of the test as it appears in your Split configuration
* `:only`: A symbol or an array of symbols corresponding to the action names you'd like this test to run for
* `:except`: A symbol or an array of symbols corresponding to the action names you'd like to exclude from the test (it will run on all actions not listed here)
* `:if`: A boolean value or Proc to be evaluated at runtime. The current controller instance is passed into the Proc for you to use

Only include either `:only` or `:except` -- if you include both, `:only` will take precedence.

## Outside Controller Access

If you'd like to manually expire your action caches in models/sweeper/wherever we give you access to create an instance of the adapter use internally.

### Instantiate an adapter

`Split::Cacheable::Adapter.new(<controller_instance>, <action_name>)`

* `controller_instance`: A new instance of an ActionController::Base subclass
* `action_name`: A symbol that corresponds to the action you want to uncache

ex: `Split::Cacheable::Adapter.new(ProductController.new, :index)`

### Then get all possible variations to uncache

`Split::Cacheable::Adapter.new(ProductController.new, :index).get_all_possible_variations`

This will return an array of all the possible cache keys ever generated so you can manually uncache your views:

```
Split::Cacheable::Adapter.new(ProductController.new, :index).get_all_possible_variations.each { |split_cache_key|
    Rails.cache.delete("views/#{split_cache_key}/#{current_host}/products")
}
```

Note that we don't evaluate the `:if` option when you instantiate the controller manually. This is because we assume `Proc`s will usually be used to decide whether to show the test based on the current request. By not evaluating the `:if`s in this scenario we are able to return all possible cache keys regardless of request type.

## Development

Source hosted at [GitHub](http://github.com/harrystech/split_cacheable).<br>
Report Issues/Feature requests on [GitHub Issues](http://github.com/harrystech/split_cacheable/issues).

[![TravisCI](https://travis-ci.org/harrystech/split_cacheable.png)](https://travis-ci.org/harrystech/split_cacheable)
