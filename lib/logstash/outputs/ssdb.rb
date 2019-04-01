# encoding: utf-8
require "logstash/outputs/base"
require "java"

jar_path = File.join(File.dirname(File.dirname(File.dirname(__FILE__))), "jars")
Dir.glob(jar_path + '/*.jar') do |jar|
  require jar
end

java_import "org.nutz.ssdb4j.SSDBs"
java_import "java.util.ArrayList"

# An ssdb output that does nothing.
class LogStash::Outputs::Ssdb < LogStash::Outputs::Base
  config_name "ssdb"

  config :ip, :validate => :string, :required => true
  config :port, :validate => :number, :received => true
  # list,hash,set类型的name
  config :name, :validate => :string, :default => ""
  # 类型,kv,list,hash,set
  config :type, :validate => :string, :default => "kv"
  # key
  config :key, :validate => :string, :default => ""
  # value
  config :value, :validate => :string, :required => true
  # batch events number in list,hash,set
  config :batch_size, :validate => :number, :default => 100

  public
  def register
    @logger = self.logger
    begin
      @ssdb = SSDBs.simple(@ip, @port, 10000)
      unless "kv".eql?(@type)
        @batch = ArrayList.new(@batch_size)
      else
        @batch = nil 
      end
    rescue => e
      raise e
    end
  end # def register

  public
  def receive(event)
    begin
      if @batch.nil?
        @ssdb.set(event.get(@key), event.get(@value));
      else#list,hash,set
        if @name.empty?
          raise "ssdb type["+@type+"] name is empty"
        end
        unless @key.empty? #hash,set
          @batch.add(event.get(@key))
        end
        @batch.add(event.get(@value))

        if @batch.size >= @batch_size
          batchWrite
        end
      end
    rescue => e
      @logger.error("fail to write", :exception => e)
    end
  end # def event

  private
  def batchWrite
    if @batch.size > 0
      case @type
      when "list" then
        @ssdb.qpush_front(@name, @batch.toArray)
      when "hash" then
        @ssdb.multi_hset(@name, @batch.toArray);
      when "set" then
        @ssdb.multi_zset(@name, @batch.toArray);
      else
        raise "ssdb type[" + @type + "] is not support"
      end
      @batch.clear
    end
  end
  
  def close
    batchWrite
    super
  end

end # class LogStash::Outputs::Ssdb

