require 'singleton'

class QuestionDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Question
  
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
    return nil unless question.length > 0
    questions.map {|question| Question.new(question)}
  end

  def initialize(questions)
    @id = questions['id']
    @title = questions['title']
    @body = questions['body']
    @associated_author = questions['associated_author']
  end

  def author
    question = QuestionDBConnection.instance.execute(<<-SQL, @associated_author)
      SELECT
        associated_author
      FROM
        questions
      WHERE
        associated_author = ?
    SQL
    return nil unless question.length > 0
    Question.new(question.first)
  end
end

