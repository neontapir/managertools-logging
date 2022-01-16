# frozen_string_literal: true

require_relative 'support/shared_contexts'
Dir['./lib/entries/*_entry.rb'].sort.each(&method(:require))

RSpec.describe GoalEntry do
  it 'gets an entry by identifier' do
    expect(DiaryEntry.get('goal')).to be(GoalEntry)
  end

  context 'with a single person' do
    include_context 'freeze_time' do
      let(:clock_date) { Time.new(2000) }
    end

    subject(:individual_goal) { GoalEntry.new(applies_to: 'Bruce Wayne') }
    let(:due_date) { Time.new(2001, 3, 2, 5, 6, 7) }

    it 'renders correctly' do
      expect(individual_goal.render('Test', GoalEntry)).not_to include('Applies to::')
    end
  end

  context 'with multiple people' do
    include_context 'freeze_time' do
      let(:clock_date) { Time.new(2001, 2, 3, 4, 5, 6).to_s }
    end

    subject(:team_goal) { GoalEntry.new(applies_to: 'Clark Kent, Bruce Wayne') }
    let(:due_date) { Time.new(2001, 3, 2, 5, 6, 7).to_s }

    it 'renders correctly' do
      expect(team_goal.to_s).to include('Development Goal',
                                        '2001-02-03',
                                        "Applies to::\n  Clark Kent, Bruce Wayne")
    end
  end
end
