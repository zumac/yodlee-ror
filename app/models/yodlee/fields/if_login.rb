module Yodlee
  module Fields
    class IfLogin < BaseField

      def input
        "<input class='form-control string #{requirement}' id='#{name}' name='#{name}' ng-model='bank.#{name}' size='#{size}' type='text' maxlength='#{maxlength}' value='#{value}' />"
      end

    end
  end
end