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

  attr_reader :title, :body
  
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


class Reply 

  attr_reader :subject, :subject_questions, :body

  def initialize(options)
    @id = options['id']
    @subject = options['subject']
    @subject_questions = options['subject_questions']
    @parent_replys = options['parent_replys']
    @user_author = options['user_author']
    @body = options['body']
  end

  def self.find_by_user_id(user_id)

    replys = QuestionDBConnection.instance.execute (<<-SQL, @user_id)
      SELECT
        *
      FROM
        replys
      WHERE
        user_author = ?
    SQL
      return nil unless replys.length > 0
      replys.map {|reply| Reply.new(reply)}
  end

  def author
    author = QuestionDBConnection.instance.execute (<<-SQL, @user_author)
      SELECT
      user_author
      FROM 
      replys
      WHERE
      user_author = ?
    SQL
    return nil unless questions.length > 0
    Replys.new(author.first)
  end

  def question
    questions = QuestionDBConnection.instance.execute (<<-SQL, @subject_question)
      SELECT 
        body
      FROM
        replys
      WHERE
      subject_question = ?
    SQL
    return nil unless questions.length > 0
    Reply.new(questions.first)
  end

  def parent_reply
    parent_reply = QuestionDBConnection.instance.execute(<<-SQL, @parent_replys)
      SELECT
        body
      FROM
        replys
      WHERE
        parent_replys = ?
    SQL
    return nil if parent_reply.length < 0
    Reply.new(parent_reply.first)
  end

  def child_reply
    child_replys = QuestionDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        body
      FROM
        replys
      WHERE
        parent_reply = ?
    SQL
    return nil unless child_reply.length > 0
    child_replys.map {|child_reply| Reply.new(child_reply)}
  end



end

