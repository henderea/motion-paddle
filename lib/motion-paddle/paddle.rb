unless defined?(Motion::Project::Config)
  raise 'This file must be required within a RubyMotion project Rakefile.'
end

class PaddleConfig
  attr_reader :options
  attr_accessor :product_id, :vendor_id, :api_key, :current_price, :dev_name, :currency, :image, 
                :product_name, :trial_duration, :trial_text, :product_image, :time_trial, :store

  def initialize(config, options)
    @config = config
    @options = options
  end

  def mas_store?
    @options[:force_mas] || ENV.fetch('store', 'paddle').downcase == 'mas'
  end

  def paddle_store?
    !@options[:force_mas] && ENV.fetch('store', 'paddle').downcase == 'paddle'
  end

  def set(var, val)
    @config.info_plist["MotionPaddle_#{@config.short_version}"] ||= [{}]
    @config.info_plist["MotionPaddle_#{@config.short_version}"].first[var.to_s] = val
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
        time_trial: time_trial,
        store: store
    }.inspect
  end
end

module Motion
  module Project
    class Config
      variable :paddle

      def paddle(options = {}, &block)
        @paddle ||= PaddleConfig.new(self, options)
        @paddle.instance_eval(&block) unless block.nil?
        @paddle.set :store, @paddle.mas_store? ? 'mas' : 'paddle'
        if @paddle.paddle_store?
          self.pods.pod 'Paddle', git: 'https://github.com/PaddleHQ/Mac-Framework.git'
        elsif @paddle.mas_store?
          self.pods.pod 'Paddle-MAS', git: 'https://github.com/PaddleHQ/Paddle-MAS.git'
        end
        @paddle
      end
    end
  end
end

Motion::Project::App.setup do |app|
  Dir.glob(File.join(File.dirname(__FILE__), '**/*.rb')).each do |file|
    if app.respond_to?('exclude_from_detect_dependencies')
      app.exclude_from_detect_dependencies << file
    end
  end

  app.files.push(File.join(File.dirname(__FILE__), 'paddle_setup.rb'))
  
  # include the correct framework for the store we're targeting
  
end