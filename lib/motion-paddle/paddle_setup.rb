class MotionPaddle
  class << self
    def enabled?
      (NSClassFromString('Paddle')!=nil)
    end

    def paddle_instance
      Paddle.sharedInstance
    end

    def product_id
      self.plist['product_id']
    end

    def vendor_id
      self.plist['vendor_id']
    end

    def api_key
      self.plist['api_key']
    end

    def current_price
      self.plist['current_price']
    end

    def dev_name
      self.plist['dev_name']
    end

    def currency
      self.plist['currency']
    end

    def image
      self.plist['image']
    end

    def product_name
      self.plist['product_name']
    end

    def trial_duration
      self.plist['trial_duration']
    end

    def trial_text
      self.plist['trial_text']
    end

    def product_image
      self.plist['product_image']
    end

    def time_trial?
      @time_trial = self.plist['time_trial'] && self.plist['time_trial'] != 0 && self.plist['time_trial'] != '0' if @time_trial.nil?
      @time_trial
    end

    def time_trial=(time_trial)
      paddle_instance.setIsTimeTrial(time_trial)
      @time_trial = time_trial
    end

    def can_force_exit?
      paddle_instance.canForceExit
    end

    def can_force_exit=(can_force_exit)
      paddle_instance.setCanForceExit(can_force_exit)
    end

    def will_show_licensing_window?
      paddle_instance.willShowLicensingWindow
    end

    def will_show_licensing_window=(will_show_licensing_window)
      paddle_instance.setWillShowLicensingWindow(will_show_licensing_window)
    end

    def setup(window = nil, &block)
      return unless enabled?
      return unless self.plist
      paddle = paddle_instance
      paddle.setProductId(product_id)
      paddle.setVendorId(vendor_id)
      paddle.setApiKey(api_key)
      paddle.startLicensing({ KPADCurrentPrice  => current_price,
                              KPADDevName       => dev_name,
                              KPADCurrency      => currency,
                              KPADImage         => image,
                              KPADProductName   => product_name,
                              KPADTrialDuration => trial_duration,
                              KPADTrialText     => trial_text,
                              KPADProductImage  => product_image }, timeTrial: time_trial?, withWindow: window)
      NSNotificationCenter.defaultCenter.addObserver(self, selector: 'activated:', name: KPADActivated, object: nil)
      NSNotificationCenter.defaultCenter.addObserver(self, selector: 'continue:', name: KPADContinue, object: nil)
      paddle.setDelegate(self)
      # block.call unless block.nil?
      listen(:activated, :continue, &block)
    end

    def listen(*names, &block)
      return if block.nil?
      @listeners ||= {}
      names.each { |name|
        @listeners[name.to_sym] ||= []
        @listeners[name.to_sym] << block
      }
    end

    def trial_days_left
      paddle_instance.daysRemainingOnTrial
    end

    def activated?
      paddle_instance.productActivated
    end

    def show_licencing
      paddle_instance.showLicencing
    end

    alias :show_licensing :show_licencing

    def activated_licence_code
      paddle_instance.activatedLicenceCode
    end

    alias :activated_license_code :activated_licence_code

    def activated_email
      paddle_instance.activatedEmail
    end

    def deactivate_licence
      paddle_instance.deactivateLicence
    end

    alias :deactivate_license :deactivate_licence

    #internal
    def plist
      (@plist = NSBundle.mainBundle.objectForInfoDictionaryKey('MotionPaddle')) && (@plist = @plist.first) unless @plist
      @plist
    end

    #internal
    def call_listeners(name, *args)
      @listeners ||= {}
      @listeners[name.to_sym].each { |block| block.call(name.to_sym, *args) } if @listeners.has_key?(name.to_sym)
    end

    #internal
    def activated(sender)
      call_listeners :activated, sender
    end

    #internal
    def continue(sender)
      call_listeners :continue, sender
    end

    #internal
    def licenceDeactivated(deactivated, message: deactivateMessage)
      call_listeners :deactivated, deactivated, deactivateMessage
    end

    #internal
    def paddleDidFailWithError(error)
      call_listeners :error, error
    end
  end
end