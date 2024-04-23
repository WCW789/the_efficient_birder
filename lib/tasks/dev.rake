desc "Fill the database tables with some sample data"
task({ :sample_data => :environment }) do

  if Rails.env.development?
    Bird.destroy_all
    User.destroy_all
    puts "Bird and user data destroyed successfully!"

    User.create([
      { username: 'Winnie', email: ENV['EMAIL'], admin: true, password: ENV['SEED_PASSWORD'] },
      { username: 'AnneAnn', email: 'anne@example.com', password: ENV['SEED_PASSWORD'] },
      { username: 'JohnJones', email: 'john@example.com', password: ENV['SEED_PASSWORD'] }
    ])

    Bird.create([
      { name: 'Heron', datetime: '2024-04-09 20:19:00 -0500', latitude: 41.879138, longitude: -88.637505, user_id: User.pluck(:id).sample },
      { name: 'Robin', datetime: '2024-04-09 20:19:00 -0500', latitude: 41.879138, longitude: -87.637505, user_id: User.pluck(:id).sample },
      { name: 'Raven', datetime: '2024-04-09 20:19:00 -0500', latitude: 42.879138, longitude: -87.637505, user_id: User.pluck(:id).sample }
    ])

  puts "Data for users and birds added!"
  end
end
