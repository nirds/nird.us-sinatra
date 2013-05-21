require 'spec_helper'

describe "nird.us App" do
  it "should respond to GET" do
    get '/'
    last_response.should be_ok
  end

  it "should respond to GET" do
    get '/renee'
    last_response.body.should include "Renée De&nbsp;Voursney"
  end

  it "should respond to GET" do
    get '/build'
    last_response.body.should include "NIRD - We Build"
  end

  it "should charge a customer" do
  	Stripe.stub(:api_key)
  	Customer = Struct.new('Customer', :id)
  	Stripe::Customer.stub(:create).and_return(Customer.new(1))
  	Charge = Struct.new('Charge', :amount)
  	Stripe::Charge.stub(:create).and_return(Charge.new(1600))
  	post = { post: {	email:        'test@nird.us',
  								  	organization: 'NIRD Test Crew',
  								  	project:      'manual test',
  								  	invoice:      '42',
  					 			  	cost:         '1600' } }
  	post '/charge', params = post
    last_response.should be_ok
  end
end
