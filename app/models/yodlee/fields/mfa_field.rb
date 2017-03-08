module Yodlee
  module Fields
    class MfaField

      attr_reader :field

      def initialize opts
        @field = opts[:field]
      end

      def question
        field.question
      end

      def response_field_type
        field.responseFieldType
      end

      def asterisk
        field.isRequired
      end

      def meta_data
        field.metaData.gsub(/\./,"").underscore
      end


      def render
       if response_field_type == 'text'
         "
          <div class='form-group'>
            <label class='control-label'>#{question} #{asterisk}</label>
            <input class='string form-control id='#{meta_data}' name='#{meta_data}' ng-model='bank.#{meta_data}' type='text' />
          </div>
        "
       end
      end

    end
  end
end