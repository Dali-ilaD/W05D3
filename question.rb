require 'singleton'
require 'sqlite3'
require_relative 'question_follow.rb'
require_relative 'users.rb'

class QuestionDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Question

  attr_accessor :id, :title, :body, :associated_author
  
  def self.find_by_id(id)
    question = QuestionDBConnection.instance.execute(<<-SQL, id)
        SELECT
          *
        FROM
          questions
        WHERE
          id = ? 
        SQL
    return nil unless question.length > 0
    Question.new(question.first)
  end

  def self.find_by_author_id(author_id)
    questions = QuestionDBConnection.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        associated_author = ?
    SQL
    return nil unless questions.length > 0
    questions.map {|question| Question.new(question)}
  end

  def initialize(questions)
    @id = questions['id']
    @title = questions['title']
    @body = questions['body']
    @associated_author = questions['associated_author']
  end

  def insert
    raise "#{self} already in database" if self.id

    QuestionDBConnection.instance.execute(<<-SQL, self.title, self.body, self.associated_author)
    INSERT INTO 
      questions ( title, body, associated_author)
    VALUES
      (?, ?, ?)
    SQL
    self.id = QuestionDBConnection.instance.last_insert_row_id
  end

  def author
    question = QuestionDBConnection.instance.execute(<<-SQL, self.associated_author)
      SELECT
        fname, lname
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil unless question.length > 0
    Users.new(question.first)
  end

  def replies 
    replies = Reply.find_by_question_id(self.id)
    replies.map {|reply| reply.body}
  end

  def followers
    question = QuestionFollow.followers_for_question_id(self.id)
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end
end

# ned = Users.find_by_name('NED','FLANDERS')
# question1 = Question.find_by_author_id(ned.id)
# # p ned.followed_questions
# # p question1[0].followers














