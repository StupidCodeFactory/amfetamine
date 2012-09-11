class Teacher < Amfetamine::Base
  @@children = [] # unrelated to relationships!

  amfetamine_attributes :name
  has_many_resources :pupils, class_name: 'Child', foreign_key: 'dummy_id'

  # Needed for proper ID tracking
  def initialize(args={})
    @@children << self
    super(args)
  end

  def self.children
    @@children ||= []
  end
end
