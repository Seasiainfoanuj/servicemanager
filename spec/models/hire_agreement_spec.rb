require "spec_helper"

describe HireAgreement do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:hire_agreement)).to be_valid
    end

    it "is valid with hire_agreement_type, vehicle, customer, manager and all attributes" do
      hire_agreement_type = create(:hire_agreement_type)
      vehicle = create(:vehicle)
      customer = create(:user, :customer)
      manager = create(:user, :admin)
      quote = create(:quote)
      invoice_company = create(:invoice_company)

      hire_agreement = create(:hire_agreement,
        type: hire_agreement_type,
        vehicle: vehicle,
        customer: customer,
        manager: manager,
        quote: quote,
        invoice_company: invoice_company,
        uid: "HIRE-123",
        status: "pending",
        pickup_time: Date.today,
        return_time: Date.today,
        pickup_location: "Brisbane",
        return_location: "Brisbane",
        seating_requirement: 12,
        daily_km_allowance: 200,
        daily_rate: 200,
        excess_km_rate: 1.3,
        damage_recovery_fee: 3000,
        fuel_service_fee: 3.6,
        details: Faker::Lorem.paragraphs
      )

      expect(hire_agreement).to be_valid
      expect(hire_agreement.resource_name).to eq('Hire Agreement hire-123')
    end

    it { should validate_presence_of :hire_agreement_type_id }
    it { should validate_presence_of :vehicle_id }
    it { should validate_presence_of :customer_id }
    it { should validate_presence_of :status }
    it { should validate_presence_of :pickup_time }
    it { should validate_presence_of :return_time }
    it { should validate_presence_of :invoice_company_id }

    describe "#number_of_days" do
      it "returns no of days as integer from pickup_time to return_time" do
        hire_agreement = create(:hire_agreement,
          pickup_time: Date.today,
          return_time: 12.days.from_now
        )
        expect(hire_agreement.number_of_days).to eq 13
      end
    end

    describe "#demurrage_days" do
      it "returns no of days as integer from demurrage_start_time to demurrage_end_time" do
        hire_agreement = create(:hire_agreement,
          demurrage_start_time: Date.today,
          demurrage_end_time: 12.days.from_now
        )
        expect(hire_agreement.demurrage_days).to eq 13
      end
    end

    describe "#km_allowance" do
      context "if daily_km_allowance present" do
        it "returns number_of_days * daily_km_allowance as integer" do
          hire_agreement = create(:hire_agreement,
            pickup_time: Date.today,
            return_time: 12.days.from_now,
            daily_km_allowance: 10
          )
          expect(hire_agreement.km_allowance).to eq 130
        end
      end

      context "if daily_km_allowance NOT present" do
        it "returns nil" do
          hire_agreement = create(:hire_agreement,
            pickup_time: Date.today,
            return_time: 12.days.from_now,
            daily_km_allowance: nil
          )
          expect(hire_agreement.km_allowance).to eq nil
        end
      end
    end

    describe "#total_km" do
      context "if on_hire_report and off_hire_report present" do
        it "returns off_hire_report.odometer_reading - on_hire_report.odometer_reading as integer" do
          hire_agreement = create(:hire_agreement)
          on_hire_report = create(:on_hire_report, hire_agreement: hire_agreement, odometer_reading: 1000)
          off_hire_report = create(:off_hire_report, hire_agreement: hire_agreement,  odometer_reading: 3000)

          expect(hire_agreement.total_km).to eq 2000
        end
      end

      context "if on_hire_report and off_hire_report NOT present" do
        it "returns nil" do
          hire_agreement = create(:hire_agreement)
          expect(hire_agreement.total_km).to eq nil
        end
      end
    end

    describe "#rental_fee" do
      context "if daily_rate present" do
        it "returns number_of_days * daily_rate as float value" do
          hire_agreement = create(:hire_agreement,
            pickup_time: Date.today,
            return_time: 12.days.from_now,
            daily_rate: 300.10
          )
          expect(hire_agreement.rental_fee).to eq 3901.3
        end
      end

      context "if daily_rate NOT present" do
        it "returns nil" do
          hire_agreement = create(:hire_agreement,
            pickup_time: Date.today,
            return_time: 12.days.from_now,
            daily_rate: nil
          )
          expect(hire_agreement.rental_fee).to eq nil
        end
      end
    end

    describe "#demurrage_fee" do
      context "if demurrage_rate present" do
        it "returns demurrage_days * demurrage_rate as float value" do
          hire_agreement = create(:hire_agreement,
            demurrage_start_time: Date.today,
            demurrage_end_time: 12.days.from_now,
            demurrage_rate: 300.10
          )
          expect(hire_agreement.demurrage_fee).to eq 3901.3
        end
      end

      context "if demurrage_rate NOT present" do
        it "returns nil" do
          hire_agreement = create(:hire_agreement,
            demurrage_start_time: Date.today,
            demurrage_end_time: 12.days.from_now,
            demurrage_rate: nil
          )
          expect(hire_agreement.demurrage_fee).to eq nil
        end
      end
    end

    describe "#total_excess_km" do
      context "with excess km" do
        it "returns excess km as integer" do
          hire_agreement = create(:hire_agreement,
            pickup_time: Date.today,
            return_time: 10.days.from_now,
            daily_km_allowance: 200
          )
          on_hire_report = create(:on_hire_report, hire_agreement: hire_agreement, odometer_reading: 1000)
          off_hire_report = create(:off_hire_report, hire_agreement: hire_agreement,  odometer_reading: 3400)

          expect(hire_agreement.total_excess_km).to eq 200
        end
      end

      context "WITHOUT excess km" do
        it "returns 0" do
          hire_agreement = create(:hire_agreement,
            pickup_time: Date.today,
            return_time: 10.days.from_now,
            daily_km_allowance: 200
          )
          on_hire_report = create(:on_hire_report, hire_agreement: hire_agreement, odometer_reading: 1000)
          off_hire_report = create(:off_hire_report, hire_agreement: hire_agreement,  odometer_reading: 2900)

          expect(hire_agreement.total_excess_km).to eq 0
        end
      end
    end

    describe "#excess_km_fee" do
      context "if total_excess_km present and excess_km_rate present?" do
        it "returns excess_km_fee as float value" do
          hire_agreement = create(:hire_agreement,
            pickup_time: Date.today,
            return_time: 10.days.from_now,
            daily_km_allowance: 200,
            excess_km_rate: 2.0
          )
          on_hire_report = create(:on_hire_report, hire_agreement: hire_agreement, odometer_reading: 1000)
          off_hire_report = create(:off_hire_report, hire_agreement: hire_agreement,  odometer_reading: 3400)

          expect(hire_agreement.excess_km_fee).to eq 400.0
        end
      end

      context "if total_excess_km NOT present / nil" do
        it "returns nil" do
          hire_agreement = create(:hire_agreement,
            pickup_time: Date.today,
            return_time: 10.days.from_now,
            daily_km_allowance: 200,
            excess_km_rate: 2.0
          )
          expect(hire_agreement.excess_km_fee).to eq nil
        end
      end
    end

    describe "#fuel_service_charge" do
      context "if off_hire_report.fuel_litres && fuel_service_fee present" do
        it "returns fuel_service_charge * fuel_service_fee as float value" do
          hire_agreement = create(:hire_agreement,
            fuel_service_fee: 3
          )
          off_hire_report = create(:off_hire_report, hire_agreement: hire_agreement,  fuel_litres: 20)
          expect(hire_agreement.fuel_service_charge).to eq 60
        end
      end

      context "if off_hire_report.fuel_litres NOT present" do
        it "returns nil" do
          hire_agreement = create(:hire_agreement)
          off_hire_report = create(:off_hire_report, hire_agreement: hire_agreement,  fuel_litres: nil)
          expect(hire_agreement.fuel_service_charge).to eq nil
        end
      end

      context "if fuel_service_fee NOT present" do
        it "returns nil" do
          hire_agreement = create(:hire_agreement)
          off_hire_report = create(:off_hire_report, hire_agreement: hire_agreement,  fuel_litres: nil)
          expect(hire_agreement.fuel_service_charge).to eq nil
        end
      end

      context "if off_hire_report NOT present" do
        it "returns nil" do
          hire_agreement = create(:hire_agreement)
          expect(hire_agreement.fuel_service_charge).to eq nil
        end
      end
    end

    describe "#pickup_datetime" do
      it "parses pickup_time into datetime format" do
        date = Date.today
        hire_agreement = create(:hire_agreement,
          pickup_time: date
        )
        expect(hire_agreement.pickup_datetime).to eq date.strftime("%Y-%m-%d %H:%M")
      end
    end

    describe "#pickup_date_field" do
      it "parses pickup_time into date format" do
        date = Date.today
        hire_agreement = create(:hire_agreement,
          pickup_time: date
        )
        expect(hire_agreement.pickup_date_field).to eq date.strftime("%d/%m/%Y")
      end
    end

    describe "#pickup_time_field" do
      it "parses pickup_time into date format" do
        date = Date.today
        hire_agreement = create(:hire_agreement,
          pickup_time: date
        )
        expect(hire_agreement.pickup_time_field).to eq date.strftime("%I:%M %p")
      end
    end

    describe "#return_datetime" do
      it "parses return_time into datetime format" do
        date = Date.today
        hire_agreement = create(:hire_agreement,
          return_time: date
        )
        expect(hire_agreement.return_datetime).to eq date.strftime("%Y-%m-%d %H:%M")
      end
    end

    describe "#return_date_field" do
      it "parses return_time into date format" do
        date = Date.today
        hire_agreement = create(:hire_agreement,
          return_time: date
        )
        expect(hire_agreement.return_date_field).to eq date.strftime("%d/%m/%Y")
      end
    end

    describe "#return_time_field" do
      it "parses return_time into date format" do
        date = Date.today
        hire_agreement = create(:hire_agreement,
          return_time: date
        )
        expect(hire_agreement.return_time_field).to eq date.strftime("%I:%M %p")
      end
    end

    describe "#date_range" do
      it "returns pickup and return times in range format" do
        pickup_time = Date.today
        return_time = 1.day.from_now
        hire_agreement = create(:hire_agreement,
          pickup_time: pickup_time,
          return_time: return_time
        )
        expect(hire_agreement.date_range).to eq "#{pickup_time.strftime("%d/%m/%Y %l:%M %p")} - #{return_time.strftime("%d/%m/%Y %l:%M %p")}"
      end

      it "accepts range and stores pickup and return times in datetime format" do
        p_time = Date.today
        r_time = 1.day.from_now
        date_range = "#{p_time.strftime("%d/%m/%Y %l:%M %p")} - #{r_time.strftime("%d/%m/%Y %l:%M %p")}"
        hire_agreement = create(:hire_agreement,
          date_range: date_range
        )
        expect(hire_agreement.pickup_time.strftime("%d/%m/%Y %l:%M %p")).to eq p_time.strftime("%d/%m/%Y %l:%M %p")
        expect(hire_agreement.return_time.strftime("%d/%m/%Y %l:%M %p")).to eq r_time.strftime("%d/%m/%Y %l:%M %p")
      end
    end

    describe "#demurrage_start_datetime" do
      it "parses demurrage_start_time into datetime format" do
        date = Date.today
        hire_agreement = create(:hire_agreement,
          demurrage_start_time: date
        )
        expect(hire_agreement.demurrage_start_datetime).to eq date.strftime("%Y-%m-%d %H:%M")
      end
    end

    describe "#demurrage_start_date_field" do
      it "parses demurrage_start_time into date format" do
        date = Date.today
        hire_agreement = create(:hire_agreement,
          demurrage_start_time: date
        )
        expect(hire_agreement.demurrage_start_date_field).to eq date.strftime("%d/%m/%Y")
      end
    end

    describe "#demurrage_start_time_field" do
      it "parses demurrage_start_time into date format" do
        date = Date.today
        hire_agreement = create(:hire_agreement,
          demurrage_start_time: date
        )
        expect(hire_agreement.demurrage_start_time_field).to eq date.strftime("%I:%M %p")
      end
    end

    describe "#demurrage_end_datetime" do
      it "parses demurrage_end_time into datetime format" do
        date = Date.today
        hire_agreement = create(:hire_agreement,
          demurrage_end_time: date
        )
        expect(hire_agreement.demurrage_end_datetime).to eq date.strftime("%Y-%m-%d %H:%M")
      end
    end

    describe "#demurrage_end_date_field" do
      it "parses demurrage_end_time into date format" do
        date = Date.today
        hire_agreement = create(:hire_agreement,
          demurrage_end_time: date
        )
        expect(hire_agreement.demurrage_end_date_field).to eq date.strftime("%d/%m/%Y")
      end
    end

    describe "#demurrage_end_time_field" do
      it "parses demurrage_end_time into date format" do
        date = Date.today
        hire_agreement = create(:hire_agreement,
          demurrage_end_time: date
        )
        expect(hire_agreement.demurrage_end_time_field).to eq date.strftime("%I:%M %p")
      end
    end

    describe "#demurrage_date_range" do
      it "demurrage_ends demurrage_start and demurrage_end times in range format" do
        demurrage_start_time = Date.today
        demurrage_end_time = 1.day.from_now
        hire_agreement = create(:hire_agreement,
          demurrage_start_time: demurrage_start_time,
          demurrage_end_time: demurrage_end_time
        )
        expect(hire_agreement.demurrage_date_range).to eq "#{demurrage_start_time.strftime("%d/%m/%Y %l:%M %p")} - #{demurrage_end_time.strftime("%d/%m/%Y %l:%M %p")}"
      end

      it "accepts range and stores demurrage_start and demurrage_end times in datetime format" do
        p_time = Date.today
        r_time = 1.day.from_now
        demurrage_date_range = "#{p_time.strftime("%d/%m/%Y %l:%M %p")} - #{r_time.strftime("%d/%m/%Y %l:%M %p")}"
        hire_agreement = create(:hire_agreement,
          demurrage_date_range: demurrage_date_range
        )
        expect(hire_agreement.demurrage_start_time.strftime("%d/%m/%Y %l:%M %p")).to eq p_time.strftime("%d/%m/%Y %l:%M %p")
        expect(hire_agreement.demurrage_end_time.strftime("%d/%m/%Y %l:%M %p")).to eq r_time.strftime("%d/%m/%Y %l:%M %p")
      end
    end

    describe "#charges_subtotal" do
      it "returns hire_charge line totals as money object" do
        hire_charges = []
        3.times { hire_charges << create(:hire_charge, amount_cents: 1000, quantity: 1) }

        hire_agreement = create(:hire_agreement, hire_charges: hire_charges)

        expect(hire_agreement.charges_subtotal.fractional).to eq 3000 # Fractional accesses money object
      end
    end

    describe "#charges_tax_total" do
      it "returns hire_charge line totals * tax_rate as money object" do
        tax_1 = create(:tax, name: 'GST', rate: 0.10)
        tax_2 = create(:tax, name: 'GST2', rate: 0.20)

        charge_1 = create(:hire_charge, amount_cents: 1000, quantity: 3, tax: tax_1)
        charge_2 = create(:hire_charge, amount_cents: 1000, quantity: 1, tax: tax_2)
        charge_3 = create(:hire_charge, amount_cents: 1000, quantity: 1, tax: nil)

        hire_charges = [charge_1, charge_2, charge_3]

        hire_agreement = create(:hire_agreement, hire_charges: hire_charges)

        expect(hire_agreement.charges_tax_total.fractional).to eq 500 # Fractional accesses money object
      end
    end

    describe "#charges_grand_total" do
      it "returns hire_charge subtotal + tax_total as money object" do
        tax_1 = create(:tax, name: 'GST', rate: 0.10)
        tax_2 = create(:tax, name: 'GST2', rate: 0.20)

        charge_1 = create(:hire_charge, amount_cents: 1000, quantity: 3, tax: tax_1)
        charge_2 = create(:hire_charge, amount_cents: 1000, quantity: 1, tax: tax_2)
        charge_3 = create(:hire_charge, amount_cents: 1000, quantity: 1, tax: nil)

        hire_charges = [charge_1, charge_2, charge_3]

        hire_agreement = create(:hire_agreement, hire_charges: hire_charges)

        expect(hire_agreement.charges_grand_total.fractional).to eq 5500 # Fractional accesses money object
      end
    end
  end

  describe "associations" do
    it { should belong_to(:type).class_name('HireAgreementType').with_foreign_key('hire_agreement_type_id') }
    it { should belong_to(:vehicle) }
    it { should belong_to(:customer).class_name('User') }
    it { should belong_to(:manager).class_name('User') }
    it { should belong_to(:quote) }
    it { should have_many(:hire_uploads) }
    it { should have_many(:notes).dependent(:destroy) }
    it { should have_many(:hire_charges).dependent(:destroy) }
    it { should have_one(:on_hire_report) }
    it { should have_one(:off_hire_report) }
    it { should belong_to(:invoice_company) }
    it { should accept_nested_attributes_for(:hire_charges).allow_destroy(true) }
  end
end
