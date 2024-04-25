desc "Fill the database tables with some sample data"
task({ :sample_data => :environment }) do

  if Rails.env.development?
    Bird.destroy_all
    User.destroy_all
    puts "Bird and user data destroyed successfully!"

    User.create([
      { username: 'Winnie', email: ENV['EMAIL'], admin: true, password: ENV['SEED_PASSWORD'] },
      { username: 'AnneAnn', email: 'anne@example.com', admin: true, password: ENV['SEED_PASSWORD'] },
      { username: 'JohnJones', email: 'john@example.com', password: ENV['SEED_PASSWORD'] }
    ])

    Bird.create([
      { name: 'Heron', datetime: '2024-04-01 09:30:00 -0500', latitude: 41.879138, longitude: -88.637505, user_id: User.pluck(:id).sample },
      { name: 'Avocet', datetime: '2024-04-02 10:19:00 -0500', latitude: 41.879138, longitude: -87.637505, user_id: User.pluck(:id).sample },
      { name: 'Toucan', datetime: '2024-04-03 15:21:00 -0500', latitude: 42.879138, longitude: -87.637505, user_id: User.pluck(:id).sample },
      { name: 'Macaw', datetime: '2024-04-04 12:25:00 -0500', latitude: 40.879138, longitude: -88.637505, user_id: User.pluck(:id).sample },
      { name: 'Oystercatcher', datetime: '2024-04-05 13:11:00 -0500', latitude: 43.879138, longitude: -85.637505, user_id: User.pluck(:id).sample },
      { name: 'Golden Eagle', datetime: '2024-04-05 21:09:00 -0500', latitude: 42.879138, longitude: -85.637505, user_id: User.pluck(:id).sample },
      { name: 'Great-Horned Owl', datetime: '2024-04-09 19:06:00 -0500', latitude: 41.879138, longitude: -85.637505, user_id: User.pluck(:id).sample },
      { name: 'Vireo', datetime: '2024-04-11 09:05:00 -0500', latitude: 43.879138, longitude: -87.637505, user_id: User.pluck(:id).sample },
      { name: 'Raven', datetime: '2024-04-20 08:33:00 -0500', latitude: 40.879138, longitude: -87.637505, user_id: User.pluck(:id).sample },
      { name: 'Goldeneye', datetime: '2024-04-21 07:50:00 -0500', latitude: 42.979138, longitude: -89.637505, user_id: User.pluck(:id).sample },
    ])

  puts "Data for users and birds added!"
  end
end
