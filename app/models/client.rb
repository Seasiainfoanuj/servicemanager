class Client < ActiveRecord::Base

  belongs_to :user
  belongs_to :company
  has_many :hire_quotes, foreign_key: 'customer_id'

  before_create :generate_reference_number

  validates :reference_number, uniqueness: true
  validates :client_type, presence: true, inclusion: { in: ['person', 'company'] }

  scope :person, -> { Client.where(client_type: 'person') }
  scope :company, -> { Client.where(client_type: 'company') }
  scope :manager, -> { Client.includes(:user).where("client_type = 'person'").references(:user).where("roles_mask = 1") }
  # scope :customer, -> { Client.includes(user: :representing_company).where("client_type = 'person'").references(:user).where("roles_mask > 1") }

  def person?
    client_type == 'person'
  end
    
  def company?
    client_type == 'company'
  end

  def employee?
    person? and user.employee?
  end

  def employer
    user.employer if employee?
  end

  def name
    company? ? company.name : user.name
  end

  def user_company
    return if company?
    employee? ? user.employer : user.representing_company
  end

  private

    def generate_reference_number
      self.reference_number = loop do
        random_id = 'CL-' + (0...2).map{ ('A'..'Z').to_a[rand(26)] }.join + (0...4).map{ (1..9).to_a[rand(9)] }.join
        break random_id unless Client.exists?(reference_number: random_id)
      end
    end

end