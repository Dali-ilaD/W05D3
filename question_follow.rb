require_relative 'question.rb'
require_relative 'users.rb'
require_relative 'reply.rb'


class QuestionFollow

    def initialize(options)
        @id = options['id']
        @questions_id = options['questions_id']
        @users_id = options['users_id']
    end

    def insert
        raise "#{self} already in database" if self.id
    
        QuestionDBConnection.instance.execute(<<-SQL, self.questions_id, self.users_id)
        INSERT INTO 
          questions ( questions_id, users_id)
        VALUES
          (?, ?)
        SQL
        self.id = QuestionDBConnection.instance.last_insert_row_id
    end

    def self.followers_for_question_id(question_id)
        followers = QuestionDBConnection.instance.execute(<<-SQL, question_id)
        SELECT
        *
        FROM
        users
        JOIN
        questions_follows
        ON 
        users.id = questions_follows.users_id
        WHERE
        questions_id = ?
        SQL
        return nil unless followers.length > 0
        followers.map{|follower| Users.new(follower)}
    end

    def self.followed_questions_for_user_id(user_id)
        questions = QuestionDBConnection.instance.execute(<<-SQL, user_id)
        SELECT 
        *
        FROM 
        questions
        LEFT JOIN
        questions_follows
        ON 
        questions.id = questions_follows.questions_id
        WHERE
        questions_follows.users_id = ?
        SQL
        return nil unless followers.length > 0
        questions.map {|question| Question.new(question)}
    end
end