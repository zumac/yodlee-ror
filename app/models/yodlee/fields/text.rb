module Yodlee
  module Fields
    class Text < BaseField

      def input
        "<input class='string form-control #{requirement}' id='#{name}' name='#{name}' ng-model='bank.#{name}' size='#{size}' type='text' maxlength='#{maxlength}' value='#{value}' />"
      end

    end
  end
end