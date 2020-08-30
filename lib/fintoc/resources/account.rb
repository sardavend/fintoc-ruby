require 'tabulate'
require 'fintoc/utils'
require 'fintoc/resources/movement'
require 'fintoc/resources/balance'

module Fintoc
  class Account
    include Utils
    attr_reader :type, :name, :holder_name, :currency
    def initialize(
      id:,
      name:,
      official_name:,
      number:,
      holder_id:,
      holder_name:,
      type:,
      currency:,
      balance: nil,
      movements: nil,
      client: nil,
      **
    )
      @id = id
      @name = name
      @official_name = official_name
      @number = number
      @holder_id = holder_id
      @holder_name = holder_name
      @type = type
      @currency = currency
      @balance = Fintoc::Balance.new(**balance)
      @movements = movements or []
      @client = client
    end

    def update_balance
      @balance = Fintoc::Balance.new(**account[:balance])
    end

    def movements(**params)
      @movements = get_movements(**params).lazy.map { |movement| Fintoc::Movement.new(**movement) }
      @movements
    end

    def update_movements(**params)
      @movements += Array.new(movements(**params))
      @movements = @movements.uniq(&:hash).sort_by(&:post_date)
    end

    def show_movements(rows = 5)
      puts("This account has #{Utils.pluralize(@movements.size, 'movement')}.")

      return unless @movements.any?

      movements = @movements.to_a.slice(0, rows)
                            .map.with_index do |mov, index|
                              [index + 1, mov.amount, mov.currency, mov.description, mov.locale_date]
                            end
      headers = ['#', 'Amount', 'Currency', 'Description', 'Date']
      puts
      puts tabulate(headers, movements, indent: 4, style: 'fancy')
    end

    def to_s
      "💰 #{@holder_name}’s #{@name} #{@balance}"
    end

    private

    def account
      @client.get.call("accounts/#{@id}")
    end

    def get_movements(**params)
      first = @client.get.call("accounts/#{@id}/movements", **params)
      params.empty? ? first : first + Utils.flatten(@client.fetch_next)

    end
  end
end
