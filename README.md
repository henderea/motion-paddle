# motion-paddle
[![Gem Version](https://badge.fury.io/rb/motion-paddle.svg)](http://badge.fury.io/rb/motion-paddle)

Paddle for vendors: <https://vendors.paddle.com>

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

###Other `MotionPaddle` methods not in the above example

* `MotionPaddle.enabled?` - true if Paddle framework is included
* `MotionPaddle.paddle_instance` - shared `Paddle` instance, typically not needed
* `MotionPaddle.time_trial?` - defaults to value from Rakefile
* `MotionPaddle.time_trial=` - override the `time_trial` value from the Rakefile
* `MotionPaddle.can_force_exit?` - gets the Paddle framework setting for whether the app is shut down normally or force exited
* `MotionPaddle.can_force_exit=` - set the above value
* `MotionPaddle.will_show_licensing_window?` - get the Paddle framework setting for whether the app will show the licensing window right away or wait until `MotionPaddle.show_licensing` is called
* `MotionPaddle.will_show_licensing_window=` - set the above value
* `MotionPaddle.trial_days_left` - get the number of days left in the trial
* `MotionPaddle.deactivate_license` - deactivate the license

**NOTE:** some methods offer a version that uses the spelling "licen**c**e".  This is the name used for the methods in the Paddle framework, so I included this spelling as an option.  The `will_show_licensing_window` methods are the only ones with it spelled with an "s" in the Paddle framework, and they do not have the "c" version in `MotionPaddle`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
