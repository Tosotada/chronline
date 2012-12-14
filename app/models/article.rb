# == Schema Information
#
# Table name: articles
#
#  id         :integer          not null, primary key
#  body       :text
#  subtitle   :string(255)
#  section    :string(255)
#  teaser     :string(255)
#  title      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'taxonomy'
require 'staff'


class Article < ActiveRecord::Base
  include FriendlyId

  attr_accessible :body, :subtitle, :section, :slug, :teaser, :title

  friendly_id :title, use: [:slugged, :history]

  validates :body, presence: true
  validates :title, presence: true
  validates :section, presence: true

  has_and_belongs_to_many :authors


  # Stolen from http://snipt.net/jpartogi/slugify-javascript/
  def normalize_friendly_id(title, max_chars=100)
    removelist = %w(a an as at before but by for from is in into like of off on
onto per since than the this that to up via with)
    r = /\b(#{removelist.join('|')})\b/i

    s = title.downcase  # convert to lowercase
    s.gsub!(r, '')
    s.strip!
    s.gsub!(/[^-\w\s]/, '')  # remove unneeded chars
    s.gsub!(/[-\s]+/, '-')   # convert spaces to hyphens
    s[0...max_chars].chomp('-')
  end

  def render_body
    BlueCloth.new(body).to_html  # Uses bluecloth markdown renderer
  end

  def section
    Taxonomy.new(self[:section])
  end

  def section=(taxonomy)
    taxonomy = Taxonomy.new(taxonomy) if not taxonomy.is_a?(Taxonomy)
    self[:section] = taxonomy.to_s
  end

end