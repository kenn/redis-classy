class Redis
  class Classy
    class << self
      attr_accessor :db

      def inherited(subclass)
        raise 'Redis::Classy.db is not assigned' unless Redis::Classy.db
        subclass.db = Redis::Namespace.new(subclass.name, :redis => Redis::Classy.db)
      end

      def delegatables
        @delegatables ||= db.class.instance_methods(false).map(&:to_sym) # ruby1.8 returns strings
      end

      def method_missing(name, *args, &block)
        return super unless delegatables.include?(name)
        db.send(name, *args, &block)
      end

      Redis::Namespace::COMMANDS.keys.each do |command|
        define_method(command) do |*args, &block|
          db.send(command, *args, &block)
        end
      end
    end

    attr_accessor :key

    def initialize(key)
      @key = key
    end

    def method_missing(name, *args, &block)
      self.class.send(name, @key, *args, &block)
    end
  end
end
