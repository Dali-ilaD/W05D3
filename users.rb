require_relative 'question.rb'
require_relative 'reply.rb'
require_relative 'question_follow.rb'

require 'sqlite3'

class Users

  attr_accessor :id, :fname, :lname

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def insert
    raise "#{self} already in database" if self.id

    QuestionDBConnection.instance.execute(<<-SQL, self.fname, self.lname)
    INSERT INTO 
      users ( fname, lname)
    VALUES
      (?, ?)
    SQL
    self.id = QuestionDBConnection.instance.last_insert_row_id
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

  def followed_questions
    questions_followed = QuestionFollow.followed_questions_for_user_id(self.id)
  end
end