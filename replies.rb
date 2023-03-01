require_relative 'questions.rb'
require_relative 'users.rb'
require 'sqlite3'

class Reply 

    attr_accessor :id, :subject, :subject_questions, :parent_replys, :user_author, :body
  
    def initialize(options)
      @id = options['id']
      @subject = options['subject']
      @subject_questions = options['subject_questions']
      @parent_replys = options['parent_replys']
      @user_author = options['user_author']
      @body = options['body']
      self.id = PlayDBConnection.instance.last_insert_row_id
    end
  
    def self.find_by_question_id(question_id)
      questions = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        subject_question
      FROM 
      replys
      WHERE
      subject_question = ?
      SQL
      return nil unless questions.length = 0
      questions.map{|question| Reply.new(question)}
    end
  
    def self.find_by_user_id(user_id)
  
      replys = QuestionDBConnection.instance.execute(<<-SQL, user_id)
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
      author = QuestionDBConnection.instance.execute(<<-SQL, @user_author)
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
      questions = QuestionDBConnection.instance.execute(<<-SQL, self.subject_question)
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
      parent_reply = QuestionDBConnection.instance.execute(<<-SQL, self.parent_replys)
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
      child_replys = QuestionDBConnection.instance.execute(<<-SQL, self.id)
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
