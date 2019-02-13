require 'spec_helper'

describe VehicleContractStatusManager do

  describe "New status after Vehicle Contract action is performed" do
    it "should suggest that after creating a vehicle contract, its status changes to 'draft'" do
      expect(VehicleContractStatusManager.status_after_action(:create)).to eq('draft')
    end

    it "should suggest that after verifying a vehicle contract, its status changes to 'verified'" do
      expect(VehicleContractStatusManager.status_after_action(:verify_customer_info)).to eq('verified')
    end

    it "should suggest that after sending a vehicle contract to the customer, its status changes to 'presented_to_customer'" do
      expect(VehicleContractStatusManager.status_after_action(:send_contract)).to eq('presented_to_customer')
    end

    it "should suggest that after the customer accepted the vehicle contract, its status changes to 'signed'" do
      expect(VehicleContractStatusManager.status_after_action(:accept)).to eq('signed')
    end

    it "should suggest that after the customer uploaded the signed vehicle contract, its status remains to 'presented_to_customer'" do
      expect(VehicleContractStatusManager.status_after_action(:upload_contract)).to eq('presented_to_customer')
    end

    it "should suggest that after the customer reviewed the vehicle contract, its status remains to 'presented_to_customer'" do
      expect(VehicleContractStatusManager.status_after_action(:review)).to eq('presented_to_customer')
    end
  end

  describe "Get permission to perform an action on a vehicle contract with a given status" do
    it "should advise that a draft vehicle contract can be updated" do
      expect(VehicleContractStatusManager.action_permitted?(:update, {current_status: 'draft'})).to be(true)
    end

    it "should advise that a verified vehicle contract can be updated" do
      expect(VehicleContractStatusManager.action_permitted?(:update, {current_status: 'verified'})).to be(true)
    end

    it "should not advise that a signed vehicle contract can be updated" do
      expect(VehicleContractStatusManager.action_permitted?( :update, {current_status: 'signed'} )).to be(false)
    end

    it "should not advise that a draft vehicle contract can be sent" do
      expect(VehicleContractStatusManager.action_permitted?(:send_contract, {current_status: 'draft'})).to be(false)
    end

    it "should advise that a verified vehicle contract can be sent" do
      expect(VehicleContractStatusManager.action_permitted?(:send_contract, {current_status: 'verified'})).to be(true)
    end

    it "should advise that a sent vehicle contract can be sent again" do
      expect(VehicleContractStatusManager.action_permitted?(:send_contract, {current_status: 'presented_to_customer'})).to be(true)
    end

    it "should advise that a sent vehicle contract can be signed" do
      expect(VehicleContractStatusManager.action_permitted?(:accept, {current_status: 'presented_to_customer'})).to be(true)
    end

    it "should advise that a sent vehicle contract can be uploaded" do
      expect(VehicleContractStatusManager.action_permitted?(:upload_contract, {current_status: 'presented_to_customer'})).to be(true)
    end

    it "should advise that a signed vehicle contract can be uploaded" do
      expect(VehicleContractStatusManager.action_permitted?(:upload_contract, {current_status: 'signed'})).to be(true)
    end

    it "should not advise that a signed vehicle contract can be sent" do
      expect(VehicleContractStatusManager.action_permitted?(:send_contract, {current_status: 'signed'})).to be(false)
    end

    it "should not advise that a verified vehicle contract can be uploaded" do
      expect(VehicleContractStatusManager.action_permitted?(:upload_contract, {current_status: 'verified'})).to be(false)
    end

    it "should not advise that a signed vehicle contract can be verified" do
      expect(VehicleContractStatusManager.action_permitted?(:verify_customer_info, {current_status: 'signed'})).to be(false)
    end
  end
end
