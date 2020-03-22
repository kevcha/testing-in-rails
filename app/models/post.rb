class Post < ApplicationRecord
  validates :title, :body, presence: true

  def publish!
    update(published: true)
  end
end
