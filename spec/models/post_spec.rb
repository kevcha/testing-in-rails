require 'rails_helper'

describe Post do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:body) }

  describe '#published!' do
    it 'sets post as published' do
      # initial condition : instance creation, etc.
      post = Post.create(title: 'Hello world', body: 'lorem ipsum', published: false)

      # execution of what will be test
      post.publish!

      # expectations
      expect(post).to be_published
    end
  end
end
