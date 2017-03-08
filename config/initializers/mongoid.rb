module Mongoid
  module Document

    def to_map
      attributes = self.attributes
      map = {:id=> self.id.to_s}
      self.fields.each do |db_field_name, mongoid_field|
        if mongoid_field.options && mongoid_field.options[:as]
          key = mongoid_field.options[:as]
        else
          key = db_field_name
        end
        map[key] = attributes[db_field_name]
      end
      self.embedded_relations.each do |field_name, meta_data|
        if(meta_data[:relation] == Mongoid::Relations::Embedded::Many)
          map[field_name] = []
          self.send(field_name).each do |emb_obj|
            map[field_name] << emb_obj.to_map
          end
        else
          map[field_name] = self.send(field_name).to_map
        end
      end
      map.delete '_id'
      map
    end

    def serializable_hash(options = nil)
      h = super(options)
      h['id'] = h.delete('_id') if(h.has_key?('_id'))
      h
    end

  end
end

module BSON
  class ObjectId
    alias :to_json :to_s
    alias :as_json :to_s
  end
end