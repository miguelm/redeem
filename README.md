Redeem
==========

This gem provides redeem capability for ActiveRecord models. It can be used for coupons, tickets, etc.

Usage
-----

### Add redeem capability to your ActiveRecord model

    class Ticket < ActiveRecord::Base
        redeemable :valid_for => 30.days, :default_number_of_uses => 4, :code_length => 8
    end

Make sure that the model has following attributes:

code:string, uses:integer, issued_at:datetime, expires_at:datetime, created_at:datetime 


### Generate the model

    rails generate redeem ClassName attributes

Generator automatically adds the following attributes to the model:

code:string, uses:integer, issued_at:datetime, expires_at:datetime, created_at:datetime


### Create the model instance

Redeem generates an unique code automatically
    
    t = Ticket.create
    t.code
    > "0F9C7891"
    
or you can declare it manually 
    
    t = Ticket.create(:code => "123456")
    t.code
    > "123456"

### Methods

Check if the coupon has already been redeemed

    t = Ticket.create(:code => "123456")
    t.redeemed?
    > true or false 

Redeems the coupon

    t = Ticket.create(:code => "123456")
    t.redeem!
    > true (if redeemed) or false 

Checks if the coupon can be redeemed

    t = Ticket.create(:code => "123456")
    t.can_be_redeemed?
    > true  or false 
 
Checks if the coupon has expired the coupon

    t = Ticket.create(:code => "123456")
    t.expired?
    > true (if redeemed) or false 
    
Copyright
---------

Copyright © 2010 Grzegorz Kazulak, Adam Lipka. See LICENSE for details. 

Credits
-------

Based on ActsAsRedeemable/Squeejee 

