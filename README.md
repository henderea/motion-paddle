# motion-paddle
[![Gem Version](https://badge.fury.io/rb/motion-paddle.svg)](http://badge.fury.io/rb/motion-paddle)

Paddle for vendors: <https://vendors.paddle.com>

As of version 1.1.3, the Paddle framework is automatically included as a CocoaPod.

In version 1.1.4, a workaround was added for an issue related to existing installations of an app using `motion-paddle` not getting updated values when something was changed in the Rakefile.  Now, the short version string is used in the section name of the `motion-paddle` part of the Info.plist.  **You will need to set `app.short_version` before calling `app.paddle`.**

You can see the gem in use in my MemoryTamer app <https://github.com/henderea/MemoryTamer>.

## Installation

Add this line to your application's Gemfile:

    gem 'motion-paddle'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install motion-paddle

## Usage

###In Rakefile:

```ruby
Motion::Project::App.setup do |app|
  #...
  app.paddle do
    set :product_id, 'product_id'
    set :vendor_id, 'vendor_id'
    set :api_key, 'api_key'
    set :current_price, 'current_price'
    set :dev_name, 'dev_name'
    set :currency, 'currency'
    set :image, 'image'
    set :product_name, 'product_name'
    set :trial_duration, 'trial_duration'
    set :trial_text, 'trial_text'
    set :product_image, 'product_image'
    set :time_trial, true
  end
end
```

### In app_delegate.rb

```ruby
def applicationDidFinishLaunching(notification)
  MotionPaddle.setup(window = nil) { |action, note|
    if MotionPaddle.activated?
      NSLog "activated with license code #{MotionPaddle.activated_license_code} and email #{MotionPaddle.activated_email}"
    else
      NSLog "not activated"
    end
    if action == :activated
      do_something_on_activated
    elsif action == :continue
      do_something_on_continue
    end
  }
  MotionPaddle.listen(:deactivated) { |action, deactivated, deactivateMessage|
    if deactivated
      NSLog 'deactivated license'
      MotionPaddle.show_licensing
    else
      NSLog "failed to deactivate license: #{deactivateMessage}"
    end
  }
  MotionPaddle.listen(:error) { |action, nsError|
    do_something_with_error
  }
end
```

### Choosing which store to build for

Use the `store` environment variable to choose which version of the Paddle framework 
you wish to use: the one for the Paddle store or for the Mac App Store.

```
rake store=paddle
rake store=mas
```

If you are building an app that will run on both the Paddle store and the Mac App Store,
you will want to update your `Rakefile` to something like this:

```ruby
Motion::Project::App.setup do |app|
  #...
  app.paddle do
    if mas_store?
      set :product_id, 'mas_product_id'
    else
      set :product_id, 'product_id'
    end
    set :vendor_id, 'vendor_id'
    set :api_key, 'api_key'
    
    ...
    
  end
end
```

If you will **only** be doing the mac app store, you can avoid having to use the environment variable every time by changing your `Rakefile` to do something like this:

```ruby
Motion::Project::App.setup do |app|
  #...
  app.paddle(force_mas: true) do
    set :product_id, 'mas_product_id'
    set :vendor_id, 'vendor_id'
    set :api_key, 'api_key'
    
    ...
    
  end
end
```

There is also a `paddle_store?` method available in the block passed to `app.paddle`


###Other `MotionPaddle` methods not in the above example

* `MotionPaddle.enabled?` - true if Paddle framework is included
* `MotionPaddle.paddle_instance` - shared `Paddle` instance, typically not needed
* `MotionPaddle.time_trial?` - defaults to value from Rakefile
* `MotionPaddle.time_trial=` - override the `time_trial` value from the Rakefile
* `MotionPaddle.can_force_exit?` - gets the Paddle framework setting for whether the app is shut down normally or force exited
* `MotionPaddle.can_force_exit=` - set the above value
* `MotionPaddle.will_show_licensing_window?` - get the Paddle framework setting for whether the app will show the licensing window right away or wait until `MotionPaddle.show_licensing` is called
* `MotionPaddle.will_show_licensing_window=` - set the above value
* `MotionPaddle.has_tracking_started?` - get the Paddle framework property `hasTrackingStarted`
* `MotionPaddle.has_tracking_started=` - set the above property (not sure if it can actually be set)
* `MotionPaddle.will_simplify_views?` - get the Paddle framework property `willSimplifyViews`
* `MotionPaddle.will_simplify_views=` - set the above property (not sure if it can actually be set)
* `MotionPaddle.will_show_activation_alert?` - get the Paddle framework property `willShowActivationAlert`
* `MotionPaddle.will_show_activation_alert=` - set the above property
* `MotionPaddle.will_continue_at_trial_end?` - get the Paddle framework setting for whether the app will force license or quit on trial end or will allow use to continue with (optionally) limited functionality
* `MotionPaddle.will_continue_at_trial_end=` - set the above property
* `MotionPaddle.trial_days_left` - get the number of days left in the trial
* `MotionPaddle.deactivate_license` - deactivate the license
* `MotionPaddle.paddle_store?` - returns true if using the Paddle store
* `MotionPaddle.mas_store?` - returns true if using the Mac App Store

**NOTE:** some methods offer a version that uses the spelling "licen**c**e".  This is the name used for the methods in the Paddle framework, so I included this spelling as an option.  The `will_show_licensing_window` methods are the only ones with it spelled with an "s" in the Paddle framework, and they do not have the "c" version in `MotionPaddle`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
