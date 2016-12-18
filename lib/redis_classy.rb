class RedisClassy
  class << self
    attr_writer :redis

    Redis::Namespace::COMMANDS.keys.each do |command|
      define_method(command) do |*args, &block|
        if @singleton
          new('singleton').send(command, *args, &block)
        else
          redis.send(command, *args, &block)
        end
      end
    end

    def redis
      @redis ||= begin
        if self == RedisClassy
          # only RedisClassy itself holds the raw non-namespaced Redis instance
          nil
        else
          # subclasses of RedisClassy
          raise Error.new('RedisClassy.redis must be assigned first') if RedisClassy.redis.nil?
          Redis::Namespace.new(self.name, redis: RedisClassy.redis)
        end
      end
    end

    def on(key)
      new(key)
    end

    def method_missing(command, *args, &block)
      if @singleton
        new('singleton').send(command, *args, &block)
      else
        super
      end
    end

    # Singletons

    attr_reader :singletons_keys

    def singletons(*args)
      args.each do |key|
        @singletons_keys ||= []
        @singletons_keys << key
        define_singleton_method(key) do
          new key
        end
      end
    end

    def singleton
      @singleton = true
    end
  end

  # Instance methods

  attr_accessor :key, :redis, :object

  def initialize(object)
    @redis = self.class.redis
    @object = object

    case object
    when String, Symbol, Integer
      @key = object.to_s
    else
      if object.respond_to?(:id)
        @key = object.id.to_s
      else
        raise ArgumentError, 'object must be a string, symbol, integer or respond to :id method'
      end
    end
  end

  KEYLESS_COMMANDS = [:multi, :pipelined, :exec, :eval, :unwatch]

  def method_missing(command, *args, &block)
    if @redis.respond_to?(command)
      case command
      when *KEYLESS_COMMANDS
        @redis.send(command, *args, &block)
      else
        @redis.send(command, @key, *args, &block)
      end
    else
      super
    end
  end

  Error = Class.new(StandardError)
end
