

class QuestionLike

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


def  self.likers_for_question_id(question_id)
    likes = QuestionDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
    fname
    FROM
    users
    JOIN
    questions_likes
    ON 
    questions_likes.users_id = users.id
    WHERE
    questions_likes.question_id = ?
    SQL
end

def self.num_likes_for_question_id(question_id)
    num_likes = QuestionDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
    COUNT(questions_id)
    FROM
    questions_likes
    GROUP BY 
    questions_id
    WHERE
    questions_likes.questions_id = ?
    SQL
end

def self.liked_questions_for_user_id(user_id)
    liked_questions = QuestionDBConnection.instance.execute(<<-SQL, user_id)
    SELECT
    body
    FROM
    questions
    JOIN 
    questions_likes
    ON 
    questions_likes.questions_id = questions.id
    WHERE
    questions_likes.users_id = ?
    SQL
end
end