# encoding: utf-8
require 'rails_helper'

RSpec.describe Entry, type: :model do
  describe 'basic entry' do
    before(:each) { @entry = create(:entry) }

    it { should respond_to(:title) }
    it { should respond_to(:body) }
    it { should respond_to(:public) }

    it 'factory entry created as expected' do
      expect(@entry).to be_valid
    end

    it 'can be assigned a user' do
      expect(@entry.user).to be nil
      @user = create(:user)
      @entry.user = @user
      @entry.save
      expect(@entry.user).to be @user
    end

    it 'is not public' do
      expect(@entry.public?).to eq false
    end

    it 'is public' do
      @entry[:public] = true
      @entry.save
      expect(@entry.public?).to eq true
    end
  end

  it 'should be invalid with a blank or nil title' do
    expect(build(:entry, title: nil)).to_not be_valid
    expect(build(:entry, title: '')).to_not be_valid
    expect(build(:entry, title: '   ')).to_not be_valid
  end

  describe 'scopes & filter' do
    before(:all) do
      Entry.delete_all  # TODO: transactional tests, clean db after each run!
      @user    = create(:user)
      @visitor = create(:visitor, user: @user)
      @friend  = create(:user)

      @entries = {
        user_ent_1: create(:entry, user: @user, public: true),
        user_ent_2: create(:entry, user: @user, public: false),
        publ_orph:  create(:entry, user: nil, public: true),
        priv_orph:  create(:entry, user: nil, public: false),
        publ_ent:   create(:entry, user: @friend, public: true),
        priv_ent:   create(:entry, user: @friend, public: false)
      }
    end

    it '.is_public should only surface public entries' do
      public_entries = Entry.is_public
      included = @entries.filtered_vals(:user_ent_1, :publ_ent, :publ_orph)
      expect(public_entries.sort).to match_array(included.sort)
    end

    it '.visible_to(user) should only surface entries visible to user' do
      visible = Entry.visible_to(user: @user)
      included = @entries.filtered_vals(:user_ent_1, :user_ent_2,
                                        :publ_ent,   :publ_orph)
      expect(visible.count).to eq(4)
      expect(visible).to match_array(included)
    end

    it '.owned_by(user: user) should only surface entries owned by user' do
      owned_by = Entry.owned_by(user: @user)
      included = @entries.filtered_vals(:user_ent_1, :user_ent_2)
      expect(owned_by.count).to eq(2)
      expect(owned_by).to match_array(included)
    end

    it '.filter(current_visitor, "just_mine") should only surface entries owned_by user' do
      just_mine = Entry.filter(@visitor, 'just_mine')
      included = @entries.filtered_vals(:user_ent_1, :user_ent_2)
      expect(just_mine.count).to eq(2)
      expect(just_mine).to match_array(included)
    end

    it '.filter(visitor, "others") only surfaces entries visible but not owned_by user' do
      others = Entry.filter(@visitor, 'others')
      included = @entries.filtered_vals(:publ_orph, :publ_ent)
      expect(others.count).to eq(2)
      expect(others).to match_array(included)
    end

    it '.filter(current_visitor, "xxx") .filter(current_visitor) should surface default' do
      default = Entry.filter(@visitor, 'xxx')
      included = @entries.filtered_vals(:user_ent_1, :user_ent_2,
                                        :publ_ent,   :publ_orph)
      expect(default.count).to eq(4)
      expect(default).to match_array(included)

      default = Entry.filter(@visitor)
      expect(default.count).to eq(4)
      expect(default).to match_array(included)
    end

    it '.visible_to seems to disregard public entries...!!!!!!'
  end

  describe 'misc instance methods' do
    it '@entry.orphan? == false when the entry has an owner' do
      @entry = create(:entry, user: create(:user))
      expect(@entry.orphan?).to eq false
    end

    it '@entry.orphan? == true when the entry has no owner' do
      @entry = create(:entry, user: nil)
      expect(@entry.orphan?).to eq true
    end

    it '@entry.owned_by?(_user: @user) == false when @user is not @entry\'s owner' do
      @user  = build(:user)
      @entry = build(:entry, user: nil)
      expect(@entry.owned_by?(_user: @user)).to eq(false)
    end

    it '@entry.owned_by?(_user: @user) == true when @user is @entry\'s owner' do
      @user  = build(:user)
      @entry = build(:entry, user: @user)
      expect(@entry.owned_by?(_user: @user)).to eq(true)
    end

    it '@entry.visible_to?(_user: @user) == false when @user is not @entry\'s owner' do
      @user  = build(:user)
      @entry = build(:entry, public: false)
      expect(@entry.visible_to?(_user: @user)).to eq(false)
    end

    it '@entry.visible_to?(_user: @user) == true when @user is @entry\'s owner' do
      @user  = build(:user)
      @entry = build(:entry, public: true)
      expect(@entry.visible_to?(_user: @user)).to eq(true)
    end
  end
end
