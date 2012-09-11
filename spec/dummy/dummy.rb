class Dummy < Amfetamine::Base
  amfetamine_attributes :title, :description
  validates_presence_of :title, :description

  has_many_resources :children

  before_create :action_before_create
  after_create :action_after_create

  before_save :action_before_save
  after_save :action_after_save

  before_validation :action_before_validate

  def action_before_create
    Amfetamine.logger.warn "Yo, BEFORE CREATE called"
  end

  def action_after_create
    Amfetamine.logger.warn "Yo, AFTER CREATE called"
  end

  def action_before_save
  end

  def action_after_save
  end

  def action_before_validate
  end
end
