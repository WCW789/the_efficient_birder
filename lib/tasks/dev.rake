desc "Fill the database tables with some sample data"
task({ :sample_data => :environment }) do

  if Rails.env.development?
    Bird.destroy_all
    puts "Bird data destroyed successfully!"
  end
end
