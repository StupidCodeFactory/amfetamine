class Student < Amfetamine::Base
  amfetamine_attributes :name, :teacher_id, :parent_id

  belongs_to_resource :teacher
  belongs_to_resource :parent, class_name: 'Dummy', foreign_key: 'parent_id'
end
