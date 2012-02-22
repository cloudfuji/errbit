module Errbit
  module Bushido
    def self.enable_bushido!
      self.load_hooks!
      self.extend_user!
      self.disable_devise_for_bushido_controllers!
    end

    def self.extend_user!
      puts "Extending the user model"
      User.instance_eval do
        validates_presence_of   :ido_id
        validates_uniqueness_of :ido_id

        def bushido_extra_attributes(extra_attributes)
          self.name  = "#{extra_attributes['first_name'].to_s} #{extra_attributes['last_name'].to_s}"
          self.email = extra_attributes["email"]
          self.admin = true
        end
      end
    end

    def self.load_hooks!
      Dir["#{Dir.pwd}/lib/bushido/**/*.rb"].each { |file| require file }
    end

    # Temporary hack because all routes require authentication in
    # Errbit
    def self.disable_devise_for_bushido_controllers!
      puts "Disabling devise auth protection on bushido controllers"

      ::Bushido::DataController.instance_eval { before_filter :authenticate_user!, :except => [:index]  }
      ::Bushido::EnvsController.instance_eval { before_filter :authenticate_user!, :except => [:update] }
      ::Bushido::MailController.instance_eval { before_filter :authenticate_user!, :except => [:index]  }

      puts "Devise checks disabled for Bushido controllers"
    end
  end
end

if Bushido::Platform.on_bushido?
  class BushidoRailtie < Rails::Railtie
    config.to_prepare do
      puts "Enabling Bushido"
      Errbit::Bushido.enable_bushido!
      puts "Finished enabling Bushido"
    end
  end
end
