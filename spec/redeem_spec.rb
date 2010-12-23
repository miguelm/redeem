require 'spec_helper'

describe Coupon do
  describe "class methods" do
    it "should assign class attribute uses_by_default" do
      Coupon.uses_by_default.should == 1 
    end
    
    it "should assign class attribute valid_for" do
      Coupon.valid_for.should == 30.days 
    end
    
    it "should assign class attribute code_length" do
      Coupon.code_length.should == 8 
    end
    
    it "should generate alphanumeric code" do
      code = Coupon.generate_code(Coupon.code_length)
      code.length.should == 8
      match = code.match(/[0-9A-Z]*/)
      match.to_s.should == code 
    end
    
    it "should check if active code" do
      code = Coupon.create.code
      Coupon.active_code?(code).should == true
    end
    
    it "should return redeemable? true" do
      Coupon.redeemable?.should == true
    end
  end
  
  describe "initialize" do
    it "should assign expires_at with class valid_for" do
      time = Time.now
      Time.stub!(:now).and_return(time)
      coupon = Coupon.create
      coupon.expires_at.should == time + Coupon.valid_for
    end
    
    it "should assign uses with class uses_by_default" do
      coupon = Coupon.create
      coupon.uses.should == Coupon.uses_by_default
    end
  end
  
  it "should check redeemed?" do
    coupon = Coupon.create
    coupon.redeemed?.should == false
    coupon.redeem!
    coupon.redeemed?.should == true
  end
  
  describe "expired?" do
    it "should return false when isn't expired" do
      coupon = Coupon.create
      coupon.expired?.should == false
    end
    
    it "should return true" do
      coupon = Coupon.create
      after_year = Time.now + 1.year
      Time.stub!(:now).and_return(after_year)
      coupon.expired?.should == true
    end 
  end
  
  describe "can_be_redeemed?" do
    before do
      @coupon = Coupon.create
    end
    
    it "should return true when uses > 0 & not expired" do
      @coupon.can_be_redeemed?.should == true
    end
    
    it "should return false when uses = 0 & not expired" do
      @coupon.uses.should > 0
      @coupon.redeem!
      @coupon.uses.should == 0
      @coupon.expired?.should == false
      @coupon.can_be_redeemed?.should == false
    end
    
    it "should return false when uses > 0 & expired" do
      @coupon.uses.should > 0
      after_year = Time.now + 1.year
      Time.stub!(:now).and_return(after_year)
      @coupon.expired?.should == true
      @coupon.can_be_redeemed?.should == false
    end
    
    it "should return false when uses == 0 & expired" do
      @coupon.redeem!
      after_year = Time.now + 1.year
      Time.stub!(:now).and_return(after_year)
      @coupon.uses.should == 0
      @coupon.expired?.should == true
      @coupon.can_be_redeemed?.should == false
    end
  end
  
  describe "redeem!" do
    before do
      @coupon = Coupon.create
    end
    
    describe "when can be redeemed" do
      it "should assign issued_at" do
        time = Time.now
        Time.stub!(:now).and_return(time)
        @coupon.redeem!
        @coupon.issued_at.should == time
      end
      
      it "should decrease uses by 1" do
        uses = @coupon.uses
        @coupon.redeem!
        @coupon.uses.should == uses - 1
      end
      
      it "should return true" do
        @coupon.redeem!.should == true
      end
    end
    
    describe "when can't be redeemed" do
      before do
        @coupon.redeem!
      end
      
      it "should return false" do
        @coupon.redeem!.should == false
      end 
    end
  end
end
