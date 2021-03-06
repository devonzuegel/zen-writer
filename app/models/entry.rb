# app/models/entry.rb
class Entry < ActiveRecord::Base
  include Searchable

  belongs_to :user
  belongs_to :visitor

  default_scope { order(created_at: :desc) }
  scope :is_public,  -> () { where(public: true) }
  scope :owned_by,   lambda  { |user: nil, visitor: nil|
    owned_by_u  = where(user: user).where.not(user: nil)
    owned_by_v  = where(visitor: visitor).where.not(visitor: nil)
    owned_by_v |= where(user: visitor.user).where.not(user: nil) if visitor.present?
    owned_by_u | owned_by_v
  }
  scope :visible_to, lambda  { |user: nil, visitor: nil|
    is_public | owned_by(user: user, visitor: visitor)
  }

  validates :title, presence: true, allow_blank: false

  def self.labeled_filters
    [
      { label: 'All',    filter: 'default' },
      { label: 'Others', filter: 'others' },
      { label: 'Mine',   filter: 'just_mine' }
    ]
  end

  def self.filters
    labeled_filters.map { |f| f[:filter] }
  end

  def self.filter(visitor: nil, filter: 'default')
    case filter
    when 'just_mine' then owned_by(visitor: visitor)
    when 'others'    then visible_to(visitor: visitor) - owned_by(visitor: visitor)
    else             visible_to(visitor: visitor)
    end
  end

  def self.filtered_search(query: nil, visitor: nil, filter: 'default')
    filtered = filter(visitor: visitor, filter: filter)
    return filtered if query.blank?

    es_results = Entry.es_search(query)
    filtered & es_results
  end

  def orphan?
    user.nil?
  end

  def public?
    self[:public] == true   # Handles case when self.public is nil.
  end

  def owned_by?(_user: nil, _visitor: nil)
    u = user.present? && _user.present? && user.id == _user.id
    v = visitor.present? && _visitor.present? && visitor.id == _visitor.id
    u || v
  end

  def visible_to?(_user: nil, _visitor: nil)
    owned_by?(_user: _user) || owned_by?(_visitor: _visitor) || public?
  end
end

Entry.import  # Auto sync model with elastic search (TODO ??)
