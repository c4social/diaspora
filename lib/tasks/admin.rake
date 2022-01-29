namespace :admin do

  task :create, [:username, :email, :password] => :environment do |_t, args|
    user_params = {username: args[:username], email: args[:email], password: args[:password], password_confirmation: args[:password]}
    user = User.build(user_params)
    user.save!
    user.confirm
    Role.add_admin(user) if user.present?
  end

end
