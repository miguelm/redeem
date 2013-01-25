module Mongoid
  module Redeem

    #require File.dirname(__FILE__)+'/redeem/railtie.rb' if defined?(Rails) && Rails::VERSION::MAJOR == 3

    #def self.included(base)
    #  base.extend(ClassMethods)
    #end

    extend ActiveSupport::Concern

    DEFAULT_LENGTH = 16
    DEFAULT_NUM_USES = 1

    included do
      cattr_accessor :valid_for,
                     :valid_until,
                     :code_length,
                     :default_number_of_uses

      field :code, :type => String
      field :uses, :type => Integer, default: 1
      field :issued_at, :type => DateTime
      field :expires_at, :type => DateTime
    end

    module ClassMethods
      def redeemable(options = {})
        before_create :initialize_new

        self.valid_for = options[:valid_for] unless options[:valid_for].nil?
        self.valid_until = options[:valid_until] unless options[:valid_until].nil?
        #self.default_number_of_uses = options[:default_number_of_uses] unless options[:default_number_of_uses].nil?
        self.default_number_of_uses = (options[:default_number_ofuses].nil? ? DEFAULT_NUM_USES : options[:default_number_of_uses])
        self.code_length = (options[:code_length].nil? ? DEFAULT_LENGTH : options[:code_length])

        include InstanceMethods
        
        def generate_code(code_length=DEFAULT_LENGTH)
          chars = ("a".."z").to_a + ("1".."9").to_a 
          new_code = Array.new(code_length, '').collect{chars[rand(chars.size)]}.join
          Digest::MD5.hexdigest(new_code)[0..(code_length-1)].upcase
        end

        def generate_unique_code
          begin
            new_code = generate_code(self.code_length)
          end until !active_code?(new_code)
          new_code
        end
        
        def active_code?(code)
          #(find :first, :conditions => {:code => code}).nil? ? false : true
          (where :code => code).exists?
        end
      end
      
      #def redeemable?
      #  self.included_modules.include?(InstanceMethods)
      #end
    end
    
    module InstanceMethods
      
      def redeemed?
        self.issued_at != nil
      end

      def expired?
        self.expires_at < Time.now
      end
      
      def redeem!
        if self.can_be_redeemed?
          self.issued_at = Time.now
          self.uses -= 1
          self.save
          true
        else
          false
        end
      end
      
      def can_be_redeemed?
        self.uses > 0 && Time.now < self.expires_at
      end
      
      def initialize_new
        self.code = self.class.generate_unique_code if self.code == nil

        #unless self.class.valid_for.nil?
        #  self.expires_at = Time.now + self.class.valid_for
        #end
        unless self.class.valid_until.nil?
          self.expires_at = self.class.valid_until + 1.day
        end
        unless self.class.default_number_of_uses.nil?
          self.uses = self.class.default_number_of_uses
        end
      end
      
      def after_redeem() end
    end  
  end
end
