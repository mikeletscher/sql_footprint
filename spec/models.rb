class Widget < ActiveRecord::Base
  has_many :cogs
end

class Cog < ActiveRecord::Base
end
