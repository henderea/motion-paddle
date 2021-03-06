class MotionPaddle
  class << self
    def enabled?
      (NSClassFromString('Paddle') != nil)
    end
    
    def enabled_paddle_store?
      enabled? && paddle_store? 
    end

    def paddle_instance
      enabled? && Paddle.sharedInstance
    end

    def psk_instance
      enabled? && PaddleStoreKit.sharedInstance
    end

    def store
      self.plist['store'] || 'paddle'
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
      paddle_instance.setIsTimeTrial(time_trial) if enabled_paddle_store?
      @time_trial = time_trial
    end

    def can_force_exit?
      enabled_paddle_store? && paddle_instance.canForceExit
    end

    def can_force_exit=(can_force_exit)
      enabled_paddle_store? && paddle_instance.setCanForceExit(can_force_exit)
    end

    def will_show_licensing_window?
      enabled_paddle_store? && paddle_instance.willShowLicensingWindow
    end

    def will_show_licensing_window=(will_show_licensing_window)
      enabled_paddle_store? && paddle_instance.setWillShowLicensingWindow(will_show_licensing_window)
    end

    def has_tracking_started?
      enabled_paddle_store? && paddle_instance.hasTrackingStarted
    end

    def has_tracking_started=(has_tracking_started)
      enabled_paddle_store? && paddle_instance.setHasTrackingStarted(has_tracking_started)
    end

    def will_simplify_views?
      enabled_paddle_store? && paddle_instance.willSimplifyViews
    end

    def will_simplify_views=(will_simplify_views)
      enabled_paddle_store? && paddle_instance.setWillSimplifyViews(will_simplify_views)
    end

    def will_show_activation_alert?
      enabled_paddle_store? && paddle_instance.willShowActivationAlert
    end

    def will_show_activation_alert=(will_show_activation_alert)
      enabled_paddle_store? && paddle_instance.setWillShowActivationAlert(will_show_activation_alert)
    end

    def will_continue_at_trial_end?
      enabled_paddle_store? && paddle_instance.willContinueAtTrialEnd
    end

    def will_continue_at_trial_end=(will_continue_at_trial_end)
      enabled_paddle_store? && paddle_instance.setWillContinueAtTrialEnd(will_continue_at_trial_end)
    end

    def psk_valid_receipts
      enabled_paddle_store? && psk_instance.validReceipts
    end

    def psk_receipt_for_product_id(product_id)
      enabled_paddle_store? && psk_instance.receiptForProductId(product_id)
    end

    def setup(window = nil, &block)
      return unless enabled?
      return unless self.plist
      paddle = paddle_instance
      paddle.setProductId(product_id)
      paddle.setVendorId(vendor_id)
      paddle.setApiKey(api_key)
      if paddle_store?
        product_info = {KPADCurrentPrice  => current_price,
                        KPADDevName       => dev_name,
                        KPADCurrency      => currency,
                        KPADImage         => image,
                        KPADTrialText     => trial_text,
                        KPADProductName   => product_name,
                        KPADProductImage  => product_image }
        if time_trial?
          product_info.merge!({KPADTrialDuration => trial_duration})
        end
        paddle.startLicensing(product_info, timeTrial: time_trial?, withWindow: window)
        NSNotificationCenter.defaultCenter.addObserver(self, selector: 'activated:', name: KPADActivated, object: nil)
        NSNotificationCenter.defaultCenter.addObserver(self, selector: 'continue:', name: KPADContinue, object: nil)
        paddle.setDelegate(self)
        # block.call unless block.nil?
        listen(:activated, :continue, &block)
      end
    end

    def listen(*names, &block)
      return if block.nil?
      @listeners ||= {}
      names.each { |name|
        @listeners[name.to_sym] ||= []
        @listeners[name.to_sym] << block
      }
    end

    def psk_show(product_ids = nil, &block)
      return unless enabled_paddle_store?
      psk = psk_instance
      psk.setDelegate(self)
      if product_ids && !product_ids.empty?
        psk.showStoreViewForProductIds(product_ids)
      else
        psk.showStoreView
      end
      listen(:psk_purchase, &block)
    end

    def psk_show_product(product_id, &block)
      return unless enabled_paddle_store?
      psk = psk_instance
      psk.setDelegate(self)
      psk.showProduct(product_id)
      listen(:psk_purchase, &block)
      end

    def psk_purchase_product(product_id, &block)
      return unless enabled_paddle_store?
      psk = psk_instance
      psk.setDelegate(self)
      psk.purchaseProduct(product_id)
      listen(:psk_purchase, &block)
    end

    def trial_days_left
      enabled_paddle_store? && paddle_instance.daysRemainingOnTrial
    end

    def activated?
      enabled_paddle_store? && paddle_instance.productActivated
    end

    def show_licencing
      enabled_paddle_store? && paddle_instance.showLicencing
    end

    alias :show_licensing :show_licencing

    def activated_licence_code
      enabled_paddle_store? && paddle_instance.activatedLicenceCode
    end

    alias :activated_license_code :activated_licence_code

    def activated_email
      enabled_paddle_store? && paddle_instance.activatedEmail
    end

    def deactivate_licence
      enabled_paddle_store? && paddle_instance.deactivateLicence
    end

    alias :deactivate_license :deactivate_licence

    def paddle_store?
      self.plist['store'] == 'paddle'
    end

    def mas_store?
      self.plist['store'] == 'mas'
    end

    #internal
    def plist
      (@plist = NSBundle.mainBundle.objectForInfoDictionaryKey("MotionPaddle_#{NSBundle.mainBundle.infoDictionary['CFBundleShortVersionString']}")) && (@plist = @plist.first) unless @plist
      @plist
    end

    #internal
    def call_listeners(name, *args)
      @listeners ||= {}
      @listeners[name.to_sym].each { |block| block.call(name.to_sym, *args) } if @listeners.has_key?(name.to_sym)
    end

    #internal
    def activated(note)
      call_listeners :activated, note
    end

    #internal
    def continue(note)
      call_listeners :continue, note
    end

    #internal
    def licenceDeactivated(deactivated, message: deactivateMessage)
      call_listeners :deactivated, deactivated, deactivateMessage
    end

    #internal
    def paddleDidFailWithError(error)
      call_listeners :error, error
    end

    #internal
    def PSKProductPurchased(transactionReceipt)
      call_listeners :psk_purchase, transactionReceipt
    end

    #internal
    def PSKDidFailWithError(error)
      call_listeners :psk_error, error
    end

    #internal
    def PSKDidCancel
      call_listeners :psk_cancel
    end
  end
end