# frozen_string_literal: true

require 'timecop'
Dir.glob('./lib/entries/*_entry.rb', &method(:require))

RSpec.describe GoalEntry do
  it 'gets an entry by identifier' do
    expect(DiaryEntry.get('goal')).to be(GoalEntry)
  end

  context 'with multiple people' do
    let(:entry_date) { Time.new(2001, 2, 3, 4, 5, 6).to_s }

    before do
      Timecop.freeze entry_date
    end

    after do
      Timecop.return
    end

    let(:due_date) { Time.new(2001, 3, 2, 5, 6, 7).to_s }
    subject { GoalEntry.new(applies_to: 'Clark Kent, Bruce Wayne') }

    it 'renders correctly' do
      expect(subject.render('Test', GoalEntry)).to include("Applies to::\n  Clark Kent, Bruce Wayne")
    end
  end

  context 'with a single person' do
    let(:entry_date) { Time.new(2000) }

    before do
      Timecop.freeze entry_date
    end

    after do
      Timecop.return
    end

    let(:due_date) { Time.new(2001, 3, 2, 5, 6, 7) }
    subject { GoalEntry.new(applies_to: 'Bruce Wayne') }

    it 'renders correctly' do
      expect(subject.render('Test', GoalEntry)).not_to include('Applies to::')
    end
  end
end
