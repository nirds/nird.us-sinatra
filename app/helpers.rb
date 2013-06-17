require 'sinatra/base'
require 'mail'

module Sinatra
  module NirdHelpers
    def find_template(views, name, engine, &block)
      # http://www.sinatrarb.com/intro#Looking%20Up%20Template%20Files
      _, folder = views.detect { |k,v| engine == Tilt[k] }
      folder ||= views[:default]
      super(folder, name, engine, &block)
    end

    def load_yaml_into_hashie_variables
      Dir.glob("data/*.yml").each do |file|
        variable = /data\/(.*).yml/.match(file)[1]
        yaml     = YAML.load_file file

        yaml.each_value { |value| modify_strings value }
        instance_variable_set(:"@#{variable}", Hashie::Mash.new(yaml))
      end
    end

    def standardize_title(unique_title_portion)
      "NIRD - #{unique_title_portion}"
    end

    def ensure_minimum_cents(cents)
      [cents, 50].max
    end

    def extract_description(post_data)
      customer = post_data[:organization]
      project  = post_data[:project]
      invoice  = post_data[:invoice]
      "#{customer} - #{project} - #{invoice}"
    end

    def extract_stripe_customer(params)
      Stripe::Customer.create(email: params[:post][:email],
                              card:  params[:stripeToken] )
    end

    def create_charge(amount, customer, description)
      Stripe::Charge.create(amount:      amount,
                            customer:    customer.id,
                            description: description,
                            currency:    'usd' )
    end

    def soft_hyphenate(string)
      hh = Text::Hyphen.new(:language => 'en_us', :left => 2, :right => 2)
        string.split(" ").map{ |word| hh.visualize(word, "&shy;") }.join(" ")
    end

    def mail_body(post_data)
      name = post_data[:name]
      email = post_data[:email]
      organization = post_data[:organization]
      phone = post_data[:phone]
      message = post_data[:message]
      "Contact Name: #{name}
      Organization: #{organization}
      Message: #{message}
      E-mail: #{email}
      Phone: #{phone}"
    end

    def contact_mailer(body)
      mail = Mail.deliver do
        to "info@nird.us"
        from "info@nird.us"
        subject "NIRD Inquiry"
        body "#{body}"
      end
    end

    private
    def modify_strings(value)
      if value.class == Hash
        value.each_value { |v| modify_strings v }
      elsif value.class == String
        value.replace(soft_hyphenate_or_clear_bracket value.to_s)
      end
    end

    def soft_hyphenate_or_clear_bracket(string)
      if first_word(string).match(/\[.*\]/)
        remove_front_bracket(string)
      else
        soft_hyphenate(string)
      end
    end

    def remove_front_bracket(string)
      string.split(" ")[1..-1].join(" ")
    end

    def first_word(string)
      string.split(" ")[0] ? string.split(" ")[0] : ""
    end
  end
end
