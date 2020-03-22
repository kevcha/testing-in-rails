# 👋 Welcome back !

## Let's talk about tests

So, you've attended Le Wagon, and you want to go deeper! That's a great choice :)

In my humble opinion (IMHO), one thing you really need to learn and practice is testing your apps. You've only had one lecture about that, and it was about minitest, which is not the most popular test framework in ruby.

We also wrote some tests during livecodes, but you didn't practiced it, and it was not in a Rails environment.

### Let's begin

When you want to test your apps in Rails, you've got 2 main choices :
* minitest
* rspec

We'll choose [rspec](https://github.com/rspec/rspec-rails#rspec-rails---), which is the popular one, and can be plugged with a lot of other gems to ease our job. You might not have noticed, but you used rspec for the ruby part (alongside with rubocop) to test your code when you did `rake` during the bootcamp.

For that purpose I created a new rails app (which is is this repository) which will be our support.

I advice you to look a the commits one by one. The [first one](https://github.com/kevcha/testing-in-rails/commit/b53fa49) is just `rails new testing-in-rails -T` ( `-T` is here to not generate all tests stuff from rails, we'll do it manually). Also, I cleaned up a little the Gemfile, removing gems we don't need

The [second one](https://github.com/kevcha/testing-in-rails/commit/684b98e) is `rails g scaffold post title:string body:text` to generate a scaffold with model, migration, routes, controllers and views.

---

### Here we are

Before anything, we want to be able to test what we'll do, so let's add `rspec-rails` gem to our Gemfile, and run the generator, as described in the gem documentation (the Readme on GitHub).

```ruby
# Gemfile
group :development, :test do
  gem 'rspec-rails'
end
```
*NB: We don't need this gem in production, so we put it only in development and test environements.*

Then `bundle install` and `rails generate rspec:install`

This is the [third](https://github.com/kevcha/testing-in-rails/commit/187bafc) commit

The generator generate `spec/rails_helper.rb` and `spec/spec_helper.rb` files, which are basically will be both loaded when we'll run tests. So if we need to configure, or require anything for testing purpose, we'll add some lines to those files.


## Basic unit testing

Let's add a validation rule on our `Post` model and test it.

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  validates :title, :body, presence: true
end
```

We'll start by creating a specific file for testing this model -> `spec/models/post_spec.rb`

**It's really important to suffix file names by `_spec`, because rspec will look only for those files when running tests**

```ruby
# spec/models/post_spec.rb

require 'rails_helper'

describe Post do
  # We'll write our tests here
end
```

So, in this file, we start by requiring `rails_helper`, which will load all we need to be able to run this test file.

Then, it's all about `rspec` syntax (we call it a DSL, for Domain Specific Language).

We can give anything we want as argument of `describe` method, but the convention advices us to give the class we want to test (but rspec doesn't care at all).

It's always the same, we have to remember methods `describe`, and `it` (for the moment ;))

---

Let's write a test for validation rules
```ruby
# spec/models/post_spec.rb
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
```

Okay ! Let's look at this :
* The `it` method is what rspec will run. So each test should be written in a block givent to `it` method, otherwise we'll have a syntax error.
* The argument we give to `it` is, again, anything we want, rspec doesn't care. We use this argument to describe in a human way what we're testing, to make it easier to understand and maintain.
* Rspec gives us some method to ensure that the restult we expect is good. Those methods used here are `expect`, `to` and `eq`

This is really readable, isn't it?

So, we wrote 2 tests, one for the title presence validation, the other one for body. We could have wrote only one test and check for both validation, but again, the convention is to tests things indepedently as much as possible, so we prefer to write 2 tests, because we're testing 2 different things.

Also, there is a convention for writing tests (inside a `it` block). Notice the empty lines between instance creation and expectations. But we'll talk about it later ;)

Now, you can try to run those tests, just by running `rspec` in your terminal. Everything should be green 💪 (if not, maybe it's because you forgot to run `rails db:create db:migrate`)

This is the [4th commit](https://github.com/kevcha/testing-in-rails/commit/a432c70)

NB : Since we use rspec, we are used to call a test "a spec", so from now I gonna use  the word "spec" instead of "test".

---

Let's add a `published` boolean field to our `Post` model :

* `rails g migration add_published_to_posts published:boolean && rails db:migrate`

Now, let's add a method `#publish` in the `Post` model, which will update post's published field to `true` :

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  validates :title, :body, presence: true

  def publish
    update(published: true)
  end
end
```

And, as a smart developer, we cannot commit it without spec :

```ruby
# spec/models/post_spec.rb
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

  describe '#publish' do
    it 'sets post as published' do
      # initial condition : instance creation, etc.
      post = Post.create(title: 'Hello world', body: 'lorem ipsum', published: false)

      # execution of the method we want to test
      post.publish

      # expectations
      expect(post.published?).to eq(true)
    end
  end
end
```

Now run your tests, everything should be green again 🚀

What's happening here? We added a new `describe` in the spec file. We can nest as much as describe we need. The convention, when testing an instance method, is to write in `describe` the name of the method, prefixed by a `#` (this means it's an **instance** method, we would have prefixed with a `.` for a class method)

So, in this test create a post instance, giving title and body to make it valid, and `published` field set to false at begnining. Then we call `post.publish`, and we expect that the field `published` has been updated.

Now we can [commit](https://github.com/kevcha/testing-in-rails/commit/b3a4ae6) ;)

### Refactoring the post_spec file

So far so good 🙏

Let's refactor the spec file (yes we also refactor our specs 🤓, but don't worry, we don't write test for our specs 🙃)

Rspec comes with others method that we can use :
* Instead of writing for example `expect(post.valid?).to eq(false)`, we can write `expect(post).to be_valid`

When using magic methods like `be_something`, rspec will try to call the method `something?` on the instance ;)

So our spec file will become :

```ruby
# spec/models/post_spec.rb
require 'rails_helper'

describe Post do
  it 'validates presence of title' do
    post = Post.new(body: 'foo')

    expect(post).not_to be_valid
    expect(post.errors[:title]).to be_present
  end

  it 'validates presence of body' do
    post = Post.new(title: 'foo')

    expect(post).not_to be_valid
    expect(post.errors[:body]).to be_present
  end

  describe '#publish' do
    it 'sets post as published' do
      # initial condition : instance creation, etc.
      post = Post.create(title: 'Hello world', body: 'lorem ipsum', published: false)

      # execution of what will be test
      post.publish

      # expectations
      expect(post).to be_published
    end
  end
end
```

Notice the use of method `not_to` instead of `to`. This small refactor makes the spec easier to read ;)

## Shoulda-matchers

Also, testing validation presence and relationships is a really common thing. So, I'm sure you already guess it... There's a gem for that!

It's called [Shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers), from thoughtbot.

Let's use it :
```ruby
# Gemfile
group :test do
  gem 'shoulda-matchers'
end
```

This gem brings a lot of usefull built-in assertions (see the docs).
We need to make rspec loads shoulda-matchers methods when running our specs, so we'll add in `rails_helper`, at the bottom :

```ruby
# spec/rails_helper.rb

# [...]

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
```

Then we can use new methods in our `post_spec.rb` file :

```ruby
# spec/models/post.rb
require 'rails_helper'

describe Post do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:body) }

  describe '#published!' do
    it 'sets post as published' do
      # initial condition : instance creation, etc.
      post = Post.create(title: 'Hello world', body: 'lorem ipsum', published: false)

      # execution of what will be tested
      post.publish!

      # expectations
      expect(post).to be_published
    end
  end
end
```

Nice, isn't it?

Shoulda matchers brings method for validation, relationships, etc. For example :
* `it { should validate_presence_of(:foo) }`
* `it { should validate_uniqueness_of(:foo) }`
* `it { should validate_inclusion_of(:foo).in(['hello', 'world']) }`
* `it { should belong_to(:bar) }`
* `it { should have_many(:bar) }`

And a [refactor commit](https://github.com/kevcha/testing-in-rails/commit/a69c0aa)

---
## To be continued
