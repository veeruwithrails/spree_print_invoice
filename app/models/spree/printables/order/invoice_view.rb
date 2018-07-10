module Spree
  class Printables::Order::InvoiceView < Printables::Invoice::BaseView
    def_delegators :@printable,
                   :email,
                   :bill_address,
                   :ship_address,
                   :tax_address,
                   :item_total,
                   :total,
                   :payments,
                   :shipments

    def items
      tax = all_adjustments.tax
      printable.line_items.map do |item|
        tax = item.adjustments.eligible.sum(:amount)
        Spree::Printables::Invoice::Item.new(
          sku: item.variant.sku,
          name: item.variant.name,
          options_text: item.variant.options_text,
          price: item.price,
          net: item.price - tax,
          quantity: item.quantity,
          total: item.total,
          mrp: item.variant.product.mrp_price,
          tax: tax,
          tax_type: item.tax_category.tax_code
        )
      end
    end

    def firstname
      printable.tax_address.firstname
    end

    def lastname
      printable.tax_address.lastname
    end

    private

    def all_adjustments
      printable.all_adjustments.eligible
    end
  end
end
