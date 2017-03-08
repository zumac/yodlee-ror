module Yodlee
  module Fields
    class BaseField

      attr_reader :field, :wrapper

      def initialize opts
        @field = opts[:field]
        @wrapper = opts[:wrapper]
      end

      def render
        "
          <div class='form-group'>
            <label class='control-label'>#{label} #{asterisk}</label>
            #{input}
          </div>
        "
      end

      def label
        field.displayName
      end

      def asterisk
        field.isOptional ? '' : '*'
      end

      def requirement
        field.isOptional ? 'optional' : 'required'
      end

      def required?
        !field.isOptional
      end

      def size
        field['size']
      end

      def maxlength
        field.maxlength
      end

      def value
        field.value
      end

      def name
        name = field.valueIdentifier
        if wrapper.present?
          wrapper + '[' + name + ']'
        else
          name
        end
      end

      def options_text
        field['displayValidValues']
      end

      def options_value
        field['validValues']
      end


    end
  end
end