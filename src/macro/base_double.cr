module Mocks
  class BaseDouble
    macro mock(method)
      {% method_name = method.name.stringify %}
      {% method_name = "self.#{method_name.id}" if method.receiver.stringify == "self" %}
      {% method_name = method_name.id %}

      def {{method_name}}({{method.args.argify}})
        method = ::Mocks::Registry.for(@@name).fetch_method("{{method_name}}")

        {% if method.args.empty? %}
          result = method.call(::Mocks::Registry::ObjectId.build(self))
        {% else %}
          result = method.call(::Mocks::Registry::ObjectId.build(self), {{method.args}})
        {% end %}

        if result.call_original

          {% if method_name.stringify == "==" %}
            previous_def
          {% else %}

            raise ::Mocks::UnexpectedMethodCall.new(
              {% if method.args.empty? %}
                "#{self.inspect} received unexpected method call {{method_name}}[]"
              {% else %}
                "#{self.inspect} received unexpected method call {{method_name}}#{[{{method.args.argify}}]}"
              {% end %}
            )

          {% end %}

        else
          result.value
        end
      end
    end
  end
end
