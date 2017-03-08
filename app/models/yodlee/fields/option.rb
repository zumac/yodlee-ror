module Yodlee
  module Fields
    class Option < BaseField

      def input
        options = ''
        select = "<select class='string #{requirement}' id='#{name}' name='#{name}' ng-model='bank.#{name}'>"
        options_text.each_with_index do | key, index|
          options.concat("<option value=#{index}> #{key}</option>")
        end
        select.concat(options)
        select.concat('</select>')
      end

    end
  end
end