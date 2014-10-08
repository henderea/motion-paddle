unless defined?(Motion::Project::Config)
  raise 'This file must be required within a RubyMotion project Rakefile.'
end

class PaddleConfig
  attr_accessor :product_id, :vendor_id, :api_key, :current_price, :dev_name, :currency, :image, :product_name, :trial_duration, :trial_text, :product_image, :time_trial

  def initialize(config)
    @config = config
  end

  def set(var, val)
    @config.info_plist['MotionPaddle'] ||= [{}]
    @config.info_plist['MotionPaddle'].first[var.to_s] = val
    send("#{var}=", val)
  end

  def inspect
    {
        product_id: product_id,
        vendor_id: vendor_id,
        api_key: api_key,
        current_price: current_price,
        dev_name: dev_name,
        currency: currency,
        image: image,
        product_name: product_name,
        trial_duration: trial_duration,
        trial_text: trial_text,
        product_image: product_image,
        time_trial: time_trial
    }.inspect
  end
end

module Motion
  module Project
    class Config
      variable :paddle

      def paddle(&block)
        @paddle ||= PaddleConfig.new(self)
        @paddle.instance_eval(&block) unless block.nil?
        @paddle
      end

      def enable_paddle
        paddle_framework = File.expand_path(File.join(File.dirname(__FILE__), '../../vendor/Paddle.framework'))
        self.embedded_frameworks << paddle_framework
      end
    end
  end
end