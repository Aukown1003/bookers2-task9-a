class Book < ApplicationRecord
  belongs_to :user
  has_many :favorites, dependent: :destroy
  # favoritesの持つuserの情報を抜き出す！
  has_many :favorited_users, through: :favorites, source: :user

  has_many :book_comments, dependent: :destroy
  has_many :read_counts, dependent: :destroy

  # favoriteで使用するメソッドの定義
  def favorited_by(user)
    # favoritesが存在するか .exists?(カラム名: '田中'のような条件)
    # つまりuser.id を参照してあればtrue
    favorites.exists?(user_id: user.id)
  end

  validates :title,presence:true
  validates :body,presence:true,length:{maximum:200}


  # 0.days.ago.prev_week..0.days.ago.prev_week(:sunday)
  def favorite
    Book.joins(:favorites).where(favorites: {created_at: Time.current.beginning_of_week..Time.current.end_of_week}).group(:id).order("count(*) desc")
  end



   # 検索メソッド作成
  def self.search_for(search, word)
    if search == "perfect_match"
      @book = Book.where("title LIKE?","#{word}")
    elsif search == "forward_match"
      @book = Book.where("title LIKE?","#{word}%")
    elsif search == "backward_match"
      @book = Book.where("title LIKE?","%#{word}")
    elsif search == "partial_match"
      @book = Book.where("title LIKE?","%#{word}%")
    else
      @book = Book.all
    end
  end

end
