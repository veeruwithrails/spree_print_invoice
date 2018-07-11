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
      tax_type = shipment_state == stock_loc_state ? 'CGST+SGST' : 'IGST'
      printable.line_items.map do |item|
        tax = item.adjustments.eligible.sum(:amount)
        tax_cat = item.tax_category
        tax_rate = tax_cat ? tax_cat.tax_rates.sum(:amount) * 100 : 0
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
          tax_code: tax_cat.try(:tax_code),
          tax_rate: tax_rate,
          tax_type: tax_type,
          delivery_charge: item.delivery_charge
        )
      end
    end

    def firstname
      printable.tax_address.firstname
    end

    def lastname
      printable.tax_address.lastname
    end

    def stock_loc_state
      shipments.first.stock_location.state_id
    end

    def shipment_state
      ship_address.state_id
    end

    private

    def all_adjustments
      printable.adjustments.eligible
    end
  end
end
