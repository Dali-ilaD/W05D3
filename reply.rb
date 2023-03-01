require_relative 'question.rb'
require_relative 'users.rb'
require 'sqlite3'

class Reply 

    attr_accessor :id, :subject, :subject_questions, :parent_replies, :user_author, :body
  
    def initialize(options)
      @id = options['id']
      @subject = options['subject']
      @subject_questions = options['subject_questions']
      @parent_replies = options['parent_replies']
      @user_author = options['user_author']
      @body = options['body']
      self.id = PlayDBConnection.instance.last_insert_row_id
    end

    def insert
        raise "#{self} already in database" if self.id
    
        QuestionDBConnection.instance.execute(<<-SQL, self.subject, self.subject_questions, self.parent_replies, self.user_author, self.body)
        INSERT INTO 
          replies ( subject, subject_questions, parent_replies, user_author, body)
        VALUES
          (?, ?, ?, ?, ?)
        SQL
        self.id = QuestionDBConnection.instance.last_insert_row_id
      end
  
    def self.find_by_question_id(question_id)
      questions = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        subject_question
      FROM 
      replies
      WHERE
      subject_question = ?
      SQL
      return nil unless questions.length = 0
      questions.map{|question| Reply.new(question)}
    end
  
    def self.find_by_user_id(user_id)
  
      replies = QuestionDBConnection.instance.execute(<<-SQL, user_id)
        SELECT
          *
        FROM
          replies
        WHERE
          user_author = ?
      SQL
        return nil unless replies.length > 0
        replies.map {|reply| Reply.new(reply)}
    end
  
    def author
      author = QuestionDBConnection.instance.execute(<<-SQL, @user_author)
        SELECT
        user_author
        FROM 
        replies
        WHERE
        user_author = ?
      SQL
      return nil unless questions.length > 0
      Reply.new(author.first)
    end
  
    def question
      questions = QuestionDBConnection.instance.execute(<<-SQL, self.subject_question)
        SELECT 
          body
        FROM
          replies
        WHERE
        subject_question = ?
      SQL
      return nil unless questions.length > 0
      Reply.new(questions.first)
    end
  
    def parent_reply
      parent_reply = QuestionDBConnection.instance.execute(<<-SQL, self.parent_replies)
        SELECT
          body
        FROM
          replies
        WHERE
          parent_replies = ?
      SQL
      return nil if parent_reply.length < 0
      Reply.new(parent_reply.first)
    end
  
    def child_reply
      child_replies = QuestionDBConnection.instance.execute(<<-SQL, self.id)
        SELECT
          body
        FROM
          replies
        WHERE
          parent_reply = ?
      SQL
      return nil unless child_reply.length > 0
      child_replies.map {|child_reply| Reply.new(child_reply)}
    end
  end
