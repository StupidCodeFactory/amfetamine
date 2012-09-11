class Infant < Amfetamine::Base
  @@children = [] # unrelated to relationships!
  attr_accessor :name, :dummy_id

  belongs_to_resource :parent, class_name: "Dummy", foreign_key: "dummy_id"

  def initialize(args={})
    @@children << self
    super(args)
  end

  def self.children
    @@children ||= []
  end
end
