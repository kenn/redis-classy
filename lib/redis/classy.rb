class Redis
  class Classy
    class << self
      attr_accessor :db

      def inherited(subclass)
        subclass.db = Redis::Namespace.new(subclass.name, :redis => Redis::Classy.db) if Redis::Classy.db
      end

      def method_missing(method_name, *args, &block)
        db.send(method_name, *args, &block)
      end

      Redis::Namespace::COMMANDS.keys.each do |key|
        define_method(key) do |*args, &block|
          raise 'Redis::Classy.db is not assigned' unless db
          db.send(key, *args, &block)
        end
      end
    end

    attr_accessor :key

    def initialize(key)
      @key = key
    end

    def method_missing(method_name, *args, &block)
      self.class.send(method_name, key, *args, &block)
    end
  end
end
