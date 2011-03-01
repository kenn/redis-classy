require 'redis-namespace'

class Redis
  class Classy
    class << self
      attr_accessor :db

      def inherited(subclass)
        subclass.db = Redis::Namespace.new(subclass.name, :redis => self.db)
      end

      def method_missing(method_name, *args)
        self.db.send(method_name, *args)
      end
    end

    attr_accessor :key

    def initialize(key)
      self.key = key
    end

    def method_missing(method_name, *args)
      self.class.send(method_name, self.key, *args)
    end
  end
end
