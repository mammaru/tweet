require 'rubygems'
require 'active_record'

class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.integer :user_id
      t.text :body
      t.datetime :tweeted_at
      t.integer :latitude
      t.string :longitude
      t.string :autonomy_id

      t.timestamps
    end
  end
end

class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.integer :tweet_count

      t.timestamps
    end
  end
end

class CreateAutonomies < ActiveRecord::Migration
  def change
    create_table :autonomies do |t|
      t.string :name
      t.integer :tweet_count
    end
  end
end
