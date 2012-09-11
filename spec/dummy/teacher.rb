class Teacher < Amfetamine::Base
  amfetamine_attributes :name

  has_many_resources :pupils, class_name: 'Child', foreign_key: 'dummy_id'
  has_many_resources :students
end
