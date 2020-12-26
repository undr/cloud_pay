module CloudPay
  class Config
    class Repo
      DEFAULT_CONFIG_VARNAME = :'@__cloud_pay__config_name'

      def configure(name = :default)
        yield config(name)
      end

      def config(name = nil)
        name ||= default

        case name
        when Symbol
          repo[name]
        when Hash
          repo[default].merge(name)
        when CloudPay::Config
          name
        else
          raise CloudPay::Error, 'Cannot resolve config'
        end
      end

      def with_config(name)
        old_config, Thread.current[DEFAULT_CONFIG_VARNAME] = default, name
        yield
      ensure
        Thread.current[DEFAULT_CONFIG_VARNAME] = old_config
      end

      def default
        Thread.current[DEFAULT_CONFIG_VARNAME] ||= :default
      end

      private

      def repo
        @repo ||= Hash.new { |h, k| h[k] = CloudPay::Config.new }
      end
    end
  end
end
