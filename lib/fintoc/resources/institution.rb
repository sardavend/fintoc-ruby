module Fintoc
  class Institution
    def initialize(id:, name:, country:, **)
      @id = id
      @name = name
      @country = country
    end

    def to_s
      "🏦 #{@name}"
    end

    def inspect 
      "<🏦 #{@name}>"
    end
  end
end