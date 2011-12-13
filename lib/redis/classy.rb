class Redis
  class Classy
    class << self
      attr_accessor :db

      def inherited(subclass)
        subclass.db = Redis::Namespace.new(subclass.name, :redis => Redis::Classy.db)
      end

      def method_missing(method_name, *args, &block)
        self.db.send(method_name, *args, &block)
      end

      Redis::Namespace::COMMANDS.keys.each do |key|
        define_method(key) do |*args|
          self.db.send(key, *args)
        end
      end
    end

    attr_accessor :key

    def initialize(key)
      self.key = key
    end

    def method_missing(method_name, *args, &block)
      self.class.send(method_name, self.key, *args, &block)
    end
  end
end
