class Infant < Amfetamine::Base
  attr_accessor :name, :dummy_id

  belongs_to_resource :parent, class_name: "Dummy", foreign_key: "dummy_id"
end
