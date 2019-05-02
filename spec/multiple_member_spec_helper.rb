# frozen_string_literal: true

module MultipleMemberSpecHelper
	def verify_answers_propagated(answers, members)
		answers.each do |answer|
			members.each do |member|
				expect(File.readlines(member.file.path)).to include(answer)
			end
		end
	end
end