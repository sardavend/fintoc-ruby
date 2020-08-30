require 'date'
require 'fintoc/resources/transfer_account'

module Fintoc
  class Movement
    attr_reader :amount, :currency, :description
    def initialize(
      id:,
      amount:,
      currency:,
      description:,
      post_date:,
      transaction_date:,
      type:,
      recipient_account:,
      sender_account:,
      comment:,
      **
    )
      @id = id
      @amount = amount
      @currency = currency
      @description = description
      @post_date = Date.iso8601(post_date)
      @transaction_date = transaction_date and Date.iso8601(transaction_date)
      @type = type
      @recipient_account = recipient_account and Fintoc::TransferAccount.new(**recipient_account)
      @sender_account = sender_account and Fintoc::TransferAccount.new(**sender_account)
      @comment = comment
    end

    def locale_date
      @post_date.strftime('%x')
    end

    def to_s
      "#{@amount} (#{@description} @ #{locale_date})"
    end
  end
end
