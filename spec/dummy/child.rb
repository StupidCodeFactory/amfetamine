class Child < Amfetamine::Base
  attr_accessor :title, :description, :dummy_id

  belongs_to_resource :dummy
end
