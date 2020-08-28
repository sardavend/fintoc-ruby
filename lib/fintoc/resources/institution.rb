module Fintoc
  class Institution
    def initialize(id_:, name:, country:, **)
      @id_ = id_
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