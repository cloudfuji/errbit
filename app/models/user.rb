class User
  PER_PAGE = 30
  include Mongoid::Document
  include Mongoid::Timestamps

  devise *Errbit::Config.devise_modules

  field :email
  field :name
  field :admin, :type => Boolean, :default => false
  field :per_page, :type => Fixnum, :default => PER_PAGE
  field :time_zone, :default => "UTC" 

  after_destroy :destroy_watchers
  before_save :ensure_authentication_token

  validates_presence_of :name

  attr_protected :admin

  has_many :apps, :foreign_key => 'watchers.user_id'

  if Errbit::Config.user_has_username
    field :username
    validates_presence_of :username
  end

  def watchers
    apps.map(&:watchers).flatten.select {|w| w.user_id.to_s == id.to_s}
  end

  def per_page
    self[:per_page] || PER_PAGE
  end

  def watching?(app)
    apps.all.include?(app)
  end

  # Todo: Move this to a Bushido include file so Bushido-specific
  # behavior isn't sitting in the models where it's not necessary
  def bushido_extra_attributes(extra_attributes)
    self.name  = "#{extra_attributes['first_name'].to_s} #{extra_attributes['last_name'].to_s}"
    self.email = extra_attributes["email"]
    self.admin = true
  end

  protected

  def destroy_watchers
    watchers.each(&:destroy)
  end
end

