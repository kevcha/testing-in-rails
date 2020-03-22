require 'rails_helper'

describe Post do
  it 'validates presence of title' do
    post = Post.new(body: 'foo')

    expect(post.valid?).to eq(false)
    expect(post.errors[:title].present?).to eq(true)
  end

  it 'validates presence of body' do
    post = Post.new(title: 'foo')

    expect(post.valid?).to eq(false)
    expect(post.errors[:body].present?).to eq(true)
  end
end
