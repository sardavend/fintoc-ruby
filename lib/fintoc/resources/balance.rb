module Fintoc
  class Balance
    def initialize(available:, current:, limit:)
      @available = available
      @current = current
      @limit = limit
    end

    def id_
      object_id
    end

    def to_s
      "#{@available} (#{@current})"
    end

    def inspect
      "<Balance #{@available} (#{@current}>"
    end
  end
end
