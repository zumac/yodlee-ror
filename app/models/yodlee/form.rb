module Yodlee
  class Form

    attr_reader :fields, :wrapper, :mfa_fields

    def initialize opts
      @fields = opts[:fields]
      @mfa_fields = opts[:mfa_fields]
      @wrapper = opts[:wrapper]
    end

    def render
      fields.componentList.map do |element|
        if element['fieldInfoType'] == "com.yodlee.common.FieldInfoChoice"
          element['fieldInfoList'].map do | inner_element|
            unless inner_element.fieldType == nil
              type = inner_element.fieldType.typeName.downcase.classify
              Yodlee::Fields.const_get(type).new(field: inner_element, wrapper: wrapper).render
            end
          end
        else
          type = element.fieldType.typeName.downcase.classify
          Yodlee::Fields.const_get(type).new(field: element, wrapper: wrapper).render
        end
      end.join('').squish
    end

    def render_mfa_form
      if mfa_fields['mfaFieldInfoType'] == 'SECURITY_QUESTION'
        mfa_fields['questionAndAnswerValues'].map do | inner_question |
          Yodlee::Fields::MfaField.new(field: inner_question).render
        end
      end
    end

  end
end