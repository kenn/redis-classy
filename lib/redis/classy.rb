class Redis
  class Classy
    class << self
      attr_accessor :db

      def inherited(subclass)
        subclass.db = Redis::Namespace.new(subclass.name, :redis => Redis::Classy.db) if Redis::Classy.db
      end

      def method_missing(name, *args, &block)
        return super unless db.class.instance_methods(false).include?(name)
        db.send(name, *args, &block)
      end

      Redis::Namespace::COMMANDS.keys.each do |command|
        define_method(command) do |*args, &block|
          raise 'Redis::Classy.db is not assigned' unless db
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
