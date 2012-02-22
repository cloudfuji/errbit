class BushidoUserHooks < Bushido::EventObserver
  def user_added
    puts "Adding a new user with incoming data #{params.inspect}"
    puts "Devise username column: #{::Devise.cas_username_column}="
    puts "Setting username to: #{params['data'].try(:[], 'ido_id')}"

    user = User.new(:email => params['data'].try(:[], 'email'))
    user.name = user.email.split('@').first
    user.send("#{::Devise.cas_username_column}=".to_sym, params['data'].try(:[], 'ido_id'))
    user.save
  end

  def user_removed
    puts "Removing user based on incoming data #{params.inspect}"
    puts "Devise username column: #{::Devise.cas_username_column}="

    ido_id = params['data'].try(:[], 'ido_id')

    ido_id and
      User.exists?(:conditions => {::Devise.cas_username_column => ido_id}) and
      User.where(::Devise.cas_username_column => ido_id).destroy
  end
end
