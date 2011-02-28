require 'redis-namespace'

class Redis
  class Classy
    class << self
      # Here we use a class instance variable, so that different databases can be
      # assigned for each class.
      attr_accessor :db

      def inherited(subclass)
        subclass.db = Redis::Namespace.new(subclass.name, :redis => self.db)
      end

      def method_missing(method_name, *args)
        self.db.send(method_name, *args)
      end
    end

    def initialize(key)
      @key = key
    end

    def method_missing(method_name, *args)
      self.class.send(method_name, @key, *args)
    end
  end
end
