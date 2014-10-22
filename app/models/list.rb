# == Schema Information
#
# Table name: lists
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  private     :boolean          default(FALSE)
#  description :text
#

class List < ActiveRecord::Base
  attr_accessible :name, :description, :private

  belongs_to :user
  has_many :wishes, dependent: :destroy
  has_many :items, through: :wishes
  has_many :admissions, as: :accessible
  has_many :allowed_users, through: :admissions, source: :user

  accepts_nested_attributes_for :wishes, :items
  
  validates :name, presence: true, length: { maximum: 60 }
  validates :user_id, presence: true

  def self.allowed(current_user)
    if current_user
     #  allowed_users = "SELECT user_id FROM admissions WHERE (accessible_type = 'List' AND accessible_id IN (:admissions_list))"
    	# where("private = :false OR (private = :true AND :current_user IN (#{allowed_users})) OR (private = :true AND :current_user IN (user_id))", current_user: current_user.id, admissions_list: self.all.collect{|l| l.id}, false: false, true: true)
      lists = scoped.collect{|l| l if l.allowed_access(current_user) || l.private == false }
      lists.count > 1 ? lists.reject(&:nil?) : lists
    else
      where("private = :false", false: false)
    end
  end

  def allowed_access(current_user)
    if self.user == current_user
      true
    elsif self.admissions.where(user_id: current_user.id).present?
      true
    else
      false
    end
  end

end
