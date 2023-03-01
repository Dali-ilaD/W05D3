require_relative 'questions.rb'

require 'sqlite3'

class Users

  attr_accessor :id, :fname, :lname

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.find_by_name(fname, lname)
    names = QuestionDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil unless names.length > 0
    Users.new(names.first)
  end

  def authored_questions
    questions = Questions.find_by_author_id(self.id)
    questions.map {|question| question.body}
  end

  def authored_replies
    replies = Reply.find_by_user_id(self.id)
    replies.map {|reply| reply.body}
  end
end