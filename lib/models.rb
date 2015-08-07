require 'rubygems'
require 'active_record'

# Definition of objects mapped to database 
class Tweet < ActiveRecord::Base
  belongs_to :user
  has_one :autonomy 
end

class User < ActiveRecord::Base
  has_many :tweets dependent: :destory
end

class Autonomy < ActiveRecord::Base
  has_many :tweets
end
