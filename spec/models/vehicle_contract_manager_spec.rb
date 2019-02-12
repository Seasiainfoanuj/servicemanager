require 'spec_helper'

describe VehicleContractManager do

  context "Complete Vehicle Contract Process using a process manager" do

    let(:admin) { FactoryGirl.create(:user, :admin) }
    let(:customer) { FactoryGirl.create(:user, :customer) }
    let(:invoice_company) { FactoryGirl.create(:invoice_company) }
    let(:quote) { FactoryGirl.create(:quote, :accepted, invoice_company: invoice_company, manager: admin, customer: customer) }
    let(:current_user) { FactoryGirl.create(:user) }

    describe "#finalise_new_contract without vehicle or allocated stock" do
      before do
        @vehicle_contract = FactoryGirl.create(:vehicle_contract, 
              invoice_company: invoice_company, 
              manager: admin, 
              customer: customer, 
              quote: quote)
        @freezed_time = Time.utc(2016, 4, 1, 12, 0, 0)
        Timecop.freeze(@freezed_time)
      end

      after do
        Timecop.return
      end

      it "creates a shared activity" do
        PublicActivity.with_tracking do
          expect{ VehicleContractManager.finalise_new_contract(@vehicle_contract, current_user) }.to change(PublicActivity::Activity,:count).by(1)
        end
      end      

      it "creates a vehicle contract status" do
        VehicleContractManager.finalise_new_contract(@vehicle_contract, current_user)
        expect(@vehicle_contract.statuses.count).to eq(1)
        expect(@vehicle_contract.statuses.first.name).to eq("draft")
        expect(@vehicle_contract.statuses.first.changed_by).to eq(current_user)
        expect(@vehicle_contract.statuses.first.status_timestamp).to eq(@freezed_time)
      end
    end

    describe "#finalise_new_contract with allocated stock and no vehicle" do
      before do
        @allocated_stock = FactoryGirl.create(:stock)
        @vehicle_contract = FactoryGirl.create(:vehicle_contract, 
              invoice_company: invoice_company, 
              allocated_stock: @allocated_stock,
              manager: admin, 
              customer: customer, 
              quote: quote)
        VehicleContractManager.finalise_new_contract(@vehicle_contract, current_user)
        @vehicle_contract.reload
      end

      it "creates a vehicle and deletes the allocated stock" do
        expect(@vehicle_contract.allocated_stock_id).to eq(nil)
        expect(@vehicle_contract.vehicle_id).not_to eq(nil)
      end
    end

    describe "#complete_verification" do
      before do
        @vehicle_contract = FactoryGirl.create(:vehicle_contract, 
              invoice_company: invoice_company, 
              manager: admin, 
              customer: customer, 
              quote: quote)
        @freezed_time = Time.utc(2016, 4, 1, 12, 0, 0)
        Timecop.freeze(@freezed_time)
      end

      after do
        Timecop.return
      end

      it "creates a shared activity" do
        PublicActivity.with_tracking do
          expect{ VehicleContractManager.complete_verification(@vehicle_contract, current_user) }.to change(PublicActivity::Activity,:count).by(1)
        end
      end      

      it "creates a vehicle contract status" do
        VehicleContractManager.complete_verification(@vehicle_contract, current_user)
        @vehicle_contract.reload
        expect(@vehicle_contract.current_status).to eq("verified")
        expect(@vehicle_contract.statuses.first.name).to eq("verified")
        expect(@vehicle_contract.statuses.first.changed_by).to eq(current_user)
        expect(@vehicle_contract.statuses.first.status_timestamp).to eq(@freezed_time)
      end
    end

    describe "#prepare_contract_for_sending" do
      before do
        @vehicle_contract = FactoryGirl.create(:vehicle_contract, 
              invoice_company: invoice_company, 
              manager: admin, 
              customer: customer, 
              quote: quote,
              current_status: 'verified')
        @freezed_time = Time.utc(2016, 4, 1, 12, 0, 0)
        Timecop.freeze(@freezed_time)
      end

      after do
        Timecop.return
      end

      it "creates a shared activity" do
        PublicActivity.with_tracking do
          expect{ VehicleContractManager.prepare_contract_for_sending(@vehicle_contract, current_user) }.to change(PublicActivity::Activity, :count).by(1)
        end
      end      

      it "creates a vehicle contract status" do
        VehicleContractManager.prepare_contract_for_sending(@vehicle_contract, current_user)
        @vehicle_contract.reload
        expect(@vehicle_contract.current_status).to eq("presented_to_customer")
        expect(@vehicle_contract.statuses.first.name).to eq("presented_to_customer")
        expect(@vehicle_contract.statuses.first.changed_by).to eq(current_user)
        expect(@vehicle_contract.statuses.first.status_timestamp).to eq(@freezed_time)
      end
    end

    describe "#complete_upload" do
      before do
        @vehicle_contract = FactoryGirl.create(:vehicle_contract, 
              invoice_company: invoice_company, 
              manager: admin, 
              customer: customer, 
              quote: quote,
              current_status: 'presented_to_customer')
      end

      it "creates a shared activity" do
        PublicActivity.with_tracking do
          expect{ VehicleContractManager.complete_upload(@vehicle_contract, current_user) }.to change(PublicActivity::Activity, :count).by(1)
        end
      end
    end

    describe "#complete_acceptance" do
      before do
        @vehicle_contract = FactoryGirl.create(:vehicle_contract, 
              invoice_company: invoice_company, 
              manager: admin, 
              customer: customer, 
              quote: quote,
              current_status: "presented_to_customer")
        @freezed_time = Time.utc(2016, 4, 1, 12, 0, 0)
        Timecop.freeze(@freezed_time)
        @options = {current_user: customer, ip_address: '123.444.55.191'}
      end

      after do
        Timecop.return
      end

      it "creates a shared activity" do
        PublicActivity.with_tracking do
          expect{ VehicleContractManager.complete_acceptance(@vehicle_contract, @options) }.to change(PublicActivity::Activity,:count).by(1)
        end
      end      

      it "creates a vehicle contract status" do
        VehicleContractManager.complete_acceptance(@vehicle_contract, @options)
        @vehicle_contract.reload
        expect(@vehicle_contract.current_status).to eq("signed")
        expect(@vehicle_contract.statuses.first.name).to eq("signed")
        expect(@vehicle_contract.statuses.first.changed_by).to eq(@options[:current_user])
        expect(@vehicle_contract.statuses.first.status_timestamp).to eq(@freezed_time)
      end
    end

    describe "#can_replace_allocated_stock_with_vehicle" do
      before do
        @allocated_stock = FactoryGirl.create(:stock)
      end

      it "creates a shared activity" do
        expect(VehicleContractManager.can_replace_allocated_stock_with_vehicle?(@allocated_stock.id)).to eq(true)
      end
    end

    describe "#may_select_allocated_stock" do
      before do
        vehicle = FactoryGirl.create(:vehicle)
        @vehicle_contract = FactoryGirl.build(:vehicle_contract, 
              invoice_company: invoice_company, 
              manager: admin, 
              customer: customer, 
              quote: quote,
              vehicle: vehicle,
              current_status: 'signed')
      end

      it "does not allow Admin user to select allocated stock if the contract has been presented to the customer" do
        @vehicle_contract.current_status = 'signed'
        @vehicle_contract.save
        expect(VehicleContractManager.may_select_allocated_stock?(@vehicle_contract, admin)).to eq(false)
      end

      it "never allows Customer to select allocated stock" do
        @vehicle_contract.save
        expect(VehicleContractManager.may_select_allocated_stock?(@vehicle_contract, customer)).to eq(false)
      end

      it "allows an Admin to select allocated stock when a new contract is being created" do
        @vehicle_contract.vehicle_id = nil
        expect(VehicleContractManager.may_select_allocated_stock?(@vehicle_contract, admin)).to eq(true)
      end
    end
  end
end
