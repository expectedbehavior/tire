module Tire

  class Configuration

    def self.url(value=nil, &block)
      if value
        @url = case value
                when String, Symbol
                  value.to_s.gsub(%r|/*$|, '')
                else
                  value
                end
      elsif block_given?
        @url = block
      end
      if @url
        if @url.respond_to?(:call)
          @url.call
        else
          @url
        end
      else
        ENV['ELASTICSEARCH_URL'] || "http://localhost:9200"
      end
    end

    def self.client(klass=nil)
      @client = klass || @client || HTTP::Client::RestClient
    end

    def self.wrapper(klass=nil)
      @wrapper = klass || @wrapper || Results::Item
    end

    def self.logger(device=nil, options={})
      return @logger = Logger.new(device, options) if device
      @logger || nil
    end

    def self.pretty(value=nil, options={})
      if value === false
        return @pretty = false
      else
        @pretty.nil? ? true : @pretty
      end
    end

    def self.reset(*properties)
      reset_variables = properties.empty? ? instance_variables : instance_variables.map { |p| p.to_s} & \
                                                                 properties.map         { |p| "@#{p}" }
      reset_variables.each { |v| instance_variable_set(v.to_sym, nil) }
    end

    def self.http_max_content_length(value=nil)
      if value
        @http_max_content_length = value
      else
        @http_max_content_length || 104857600
      end
    end

    def self.timeout(value=nil)
      if value
        @timeout = value
      else
        @timeout
      end
    end

  end

end
