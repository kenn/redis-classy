require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Something < Redis::Classy
end

describe "RedisClassy" do
  before(:each) do
    Redis::Classy.flushdb
  end

  after(:each) do
    Redis::Classy.flushdb
  end

  after(:all) do
    Redis::Classy.quit
  end

  it "should prepend class name to the key" do
    Something.set("foo", "bar")

    Something.keys.should     == ["foo"]
    Redis::Classy.keys.should == ["Something:foo"]
  end

  it "should delegate class methods" do
    Something.get("foo").should == nil
    Something.set("foo", "bar")
    Something.get("foo").should == "bar"
  end

  it "should delegate instance methods with the key binding" do
    something = Something.new("foo")

    something.get.should == nil
    something.set("bar")
    something.get.should == "bar"
  end

  it "should handle multi block" do
    something = Something.new("foo")

    Redis::Classy.multi do
      something.sadd 1
      something.sadd 2
      something.sadd 3
    end

    something.smembers.should == ['1','2','3']
  end

  it "should battle against mongoid" do
    # Emulate notorious Mongoid::Extensions::Object::Conversions
    class Object
      def self.get(value)
        value
      end
    end

    # This would have returned "foo" instead of nil, unless we explicitly defined
    # class methods from Redis::Namespace::COMMANDS
    Something.get("foo").should == nil

    class << Object
      remove_method :get
    end
  end
end
