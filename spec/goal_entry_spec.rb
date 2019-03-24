# frozen_string_literal: true

require 'timecop'
Dir.glob('./lib/*_entry.rb', &method(:require))

describe GoalEntry do
  it 'gets an entry by identifier' do
    expect(DiaryEntry.get('goal')).to be(GoalEntry)
  end

  context 'with multiple people' do
    let (:entry_date) { Time.new(2001, 2, 3, 4, 5, 6) }

    before do
      Timecop.freeze entry_date
    end

    after do
      Timecop.return
    end

    let (:due_date) { Time.new(2001, 3, 2, 5, 6, 7).to_s }
    subject { GoalEntry.new(datetime: entry_date.to_s, applies_to: "Clark Kent, Bruce Wayne", due_date: due_date, goal: "Do better") }

    it 'renders correctly' do
      expect(subject.render('Test', GoalEntry)).to include("Applies to::\n  Clark Kent, Bruce Wayne")
    end
  end

  context 'with a single person' do
    let (:entry_date) { Time.new(2000) }

    before do
      Timecop.freeze entry_date
    end

    after do
      Timecop.return 
    end

    subject { GoalEntry.new } 

    it 'renders correctly' do
      allow(Settings.console).to receive(:ask) { 'yesterday' }
      element = subject.elements_array.select { |x| x.key == :due_date }.first
      expect(element.obtain.to_s).to include('December 31, 1999')
    end
  end
end
