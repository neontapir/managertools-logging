# frozen_string_literal: true

require 'timecop'
Dir.glob('./lib/entries/*_entry.rb', &method(:require))

RSpec.describe GoalEntry do
  it 'gets an entry by identifier' do
    expect(DiaryEntry.get('goal')).to be(GoalEntry)
  end

  context 'with a single person' do
    subject(:individual_goal) { GoalEntry.new(applies_to: 'Bruce Wayne') }
    let(:due_date) { Time.new(2001, 3, 2, 5, 6, 7) }
    let(:entry_date) { Time.new(2000) }

    before do
      Timecop.freeze entry_date
    end

    after do
      Timecop.return
    end

    it 'renders correctly' do
      expect(individual_goal.render('Test', GoalEntry)).not_to include('Applies to::')
    end
  end

  context 'with multiple people' do
    subject(:team_goal) { GoalEntry.new(applies_to: 'Clark Kent, Bruce Wayne') }
    let(:due_date) { Time.new(2001, 3, 2, 5, 6, 7).to_s }
    let(:entry_date) { Time.new(2001, 2, 3, 4, 5, 6).to_s }

    before do
      Timecop.freeze entry_date
    end

    after do
      Timecop.return
    end

    it 'renders correctly' do
      expect(team_goal.render('Test', GoalEntry)).to include("Applies to::\n  Clark Kent, Bruce Wayne")
    end
  end
end
