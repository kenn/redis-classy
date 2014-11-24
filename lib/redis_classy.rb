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
          nil
        else
          raise Error.new('RedisClassy.redis is not assigned') if RedisClassy.redis.nil?
          Redis::Namespace.new(self.name, redis: RedisClassy.redis)
        end
      end
    end

    def singletons(*args)
      args.each do |key|
        define_singleton_method(key) do
          new key
        end
      end
    end

    def singleton
      @singleton = true
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

  KEYLESS_COMMANDS = [:multi, :pipelined, :exec, :eval]

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
