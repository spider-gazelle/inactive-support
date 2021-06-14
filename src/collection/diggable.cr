module Digable(X)
  macro included
    {% methods = @type.methods.map(&.name.stringify) %}
    {% if !methods.includes? "dig" %}
      def dig(key_or_index : X, *subkeys)
        if (value = self[key_or_index]) && value.responds_to?(:dig)
          return value.dig(*subkeys)
        end
        if key_or_index.is_a? Int
          raise IndexError.new "#{self.class} value not diggable for index: #{key_or_index.inspect}"
        else
          raise KeyError.new "#{self.class} value not diggable for key: #{key_or_index.inspect}"
        end
      end

      # :nodoc:
      def dig(key_or_index : X)
        self[key_on_index]
      end

      def dig?(key_or_index : X, *subkeys)
        if (value = self[key_or_index]?) && value.responds_to?(:dig?)
          value.dig?(*subkeys)
        end
      end

      # :nodoc:
      def dig?(key_or_index : X)
        self[key_or_index]?
      end
    {% end %}
  end
end

