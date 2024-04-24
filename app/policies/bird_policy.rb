class BirdPolicy
  attr_reader :user, :bird

  def initialize(user, bird)
    @user = user
    @bird = bird
  end

  def show?
    user.id == bird.user.id
  end

  def update?
    user.id == bird.user.id
  end

  def edit?
    update?
  end
end
