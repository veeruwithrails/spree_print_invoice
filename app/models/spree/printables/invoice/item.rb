module Spree
  class Printables::Invoice::Item
    extend Spree::DisplayMoney

    attr_accessor :sku, :mrp, :name, :net, :options_text, :price, :quantity, :total, :tax, :tax_type

    money_methods :mrp, :net, :price, :total, :tax, :tax_type

    def initialize(args = {})
      args.each do |key, value|
        send("#{key}=", value)
      end
    end
  end
end
