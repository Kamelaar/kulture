class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy, :library]
  before_action :authenticate_user!, except: [:index, :show]

  # GET /books
  # GET /books.json
  def index
    @classic_books = Book.joins(:category).where('categories.name = ?', 'Classique').limit(5).order('id DESC')
    @sf_books = Book.joins(:category).where('categories.name = ?', 'Science fiction').limit(5).order('id DESC')
    @police_books = Book.joins(:category).where('categories.name = ?', 'Policier').limit(5).order('id DESC')
  end

  # GET /books/1
  # GET /books/1.json
  def show
  end

  # GET /books/new
  def new
    @book = current_user.books.build
    @categories = Category.all.map{|c| [ c.name, c.id ] }
  end

  # GET /books/1/edit
  def edit
    @categories = Category.all.map{|c| [ c.name, c.id ] }
  end

  # POST /books
  # POST /books.json
  def create
    @book = current_user.books.build(book_params)
    @book.category_id = params[:category_id] 

    respond_to do |format|
      if @book.save
        format.html { redirect_to @book, notice: "Le livre '#{@book.title}' a bien été créé." }
        format.json { render :show, status: :created, location: @book }
      else
        format.html { render :new }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  def update
    @book.category_id = params[:category_id]

    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: "Le livre '#{@book.title}' a été mis à jour."  }
        format.json { render :show, status: :ok, location: @book }
      else
        format.html { render :edit }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.json
  def destroy
    @book.destroy
    respond_to do |format|
      format.html { redirect_to books_url, notice: "Le livre à bien été supprimé." }
      format.json { head :no_content }
    end
  end

  # Add and remove books to library
  # for current_user
  def library
    type = params[:type]

    if type == "add"
      current_user.library_additions << @book
      redirect_to library_index_path, notice: "#{@book.title} a été ajouté a votre compte."

    elsif type == "remove"
      current_user.library_additions.delete(@book)
      redirect_to root_path, notice: "#{@book.title} a été retiré de votre compte."
    else
      # Type missing, nothing happens
      redirect_to book_path(@book), notice: "Une erreur s'est produite, merci de recommencer l/'opération."
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def book_params
      params.require(:book).permit(:title, :description, :author, :thumbnail, :user_id, :category_id)
    end
end
