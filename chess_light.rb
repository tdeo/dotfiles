#! /usr/bin/env ruby
# typed: strict

require 'sorbet-runtime'
require 'set'

extend T::Sig

SIZE = 8
A = 1
B = 2
C = 3
D = 4
E = 5
F = 6
G = 7
H = 8

class Piece
  extend T::Sig

  sig { returns(Integer) }
  attr_accessor :row, :col

  sig { params(row: Integer, col: Integer, opp: T::Boolean).void }
  def initialize(row: 0, col: 0, opp: false)
    @row = T.let(row, Integer)
    @col = T.let(col, Integer)
    @opp = T.let(opp, T::Boolean)
  end

  sig { params(grid: Grid).returns(T::Array[[Integer, Integer]]) }
  def covered_spots(grid)
    raise NotImplementedError
  end

  sig { returns(String) }
  def to_s
    "#{self.class.name} #{' ABCDEFGH'[col]}#{row}"
  end
end

class Pawn < Piece
  sig { params(_grid: Grid).returns(T::Array[[Integer, Integer]]) }
  def covered_spots(_grid)
    if @opp
      [[row - 1, col + 1], [row - 1, col - 1]]
    else
      [[row + 1, col + 1], [row + 1, col - 1]]
    end
  end
end

class King < Piece
  sig { params(_grid: Grid).returns(T::Array[[Integer, Integer]]) }
  def covered_spots(_grid)
    [
      [row - 1, col - 1], [row - 1, col], [row - 1, col + 1],
      [row, col - 1], [row, col + 1],
      [row + 1, col - 1], [row + 1, col], [row + 1, col + 1]
    ]
  end
end

class Knight < Piece
  sig { params(_grid: Grid).returns(T::Array[[Integer, Integer]]) }
  def covered_spots(_grid)
    [
      [row + 1, col + 2], [row + 1, col - 2],
      [row - 1, col + 2], [row - 1, col - 2],
      [row + 2, col + 1], [row + 2, col - 1],
      [row - 2, col + 1], [row - 2, col - 1]
    ]
  end
end

class DirectionalPiece < Piece
  sig { params(grid: Grid).returns(T::Array[[Integer, Integer]]) }
  def covered_spots(grid)
    res = []
    directions.each do |di, dj|
      i = row
      j = col
      while true
        i += di
        j += dj
        break if i > SIZE || i <= 0
        break if j > SIZE || j <= 0

        res << [i, j]
        break if grid[[i, j]] # there's a piece
      end
    end
    res
  end

  sig { returns(T::Array[[Integer, Integer]]) }
  def directions
    raise NotImplementedError
  end
end

class Rook < DirectionalPiece
  sig { returns(T::Array[[Integer, Integer]]) }
  def directions
    [[-1, 0], [1, 0], [0, -1], [0, 1]]
  end
end

class Bishop < DirectionalPiece
  sig { returns(T::Array[[Integer, Integer]]) }
  def directions
    [[-1, 1], [1, 1], [1, -1], [-1, -1]]
  end
end

class Queen < DirectionalPiece
  sig { returns(T::Array[[Integer, Integer]]) }
  def directions
    [
      [-1, 0], [1, 0], [0, -1], [0, 1],
      [-1, 1], [1, 1], [1, -1], [-1, -1]
    ]
  end
end

class Grid
  extend T::Sig

  sig { returns(String) }
  attr_reader :name

  sig { params(name: String).void }
  def initialize(name)
    @name = name
    @pieces = T.let([], T::Array[Piece])
    @spots = T.let([], T::Array[[Integer, Integer]])
    @grid = T.let({}, T::Hash[[Integer, Integer], T.nilable(Piece)])
    @opponents = T.let([], T::Array[Piece])
  end

  sig { params(pos: [Integer, Integer]).returns(T.nilable(Piece)) }
  def [](pos)
    @grid[pos]
  end

  sig { params(piece: Piece).returns(Grid) }
  def add_opponent(piece)
    @opponents << piece
    self
  end

  sig { params(klasses: T.class_of(Piece)).returns(Grid) }
  def add_pieces(*klasses)
    klasses.each do |klass|
      @pieces << klass.new
    end
    self
  end

  sig { params(cells: T::Array[String]).returns(Grid) }
  def add_cells(cells)
    cells.each { add_cell(_1) }
    self
  end

  sig { void }
  def find_solution
    total = @spots.permutation(@pieces.size).size.to_i
    start = Time.now

    viewed = Set.new

    @spots.permutation(@pieces.size).each_with_index do |permutation, i|
      i += 1
      key = permutation.zip(@pieces).map do |spot, entry|
        "#{spot[0]}#{spot[1]}#{entry.class.name}"
      end.sort.join(',')

      progress = (i * 50.0 / total).round
      if i % 1000 == 0 || i == total
        print "\r|#{'=' * progress}#{' ' * (50 - progress)}| #{i} / #{total} (elapsed #{(Time.now - start).round(2)} seconds)"
      end

      next if viewed.include?(key)

      viewed << key

      permutation.zip(@pieces).each do |spot, piece|
        T.must(piece).row = spot[0]
        T.must(piece).col = spot[1]
      end

      next unless valid?

      puts "\n"
      assist
      return
    end
  end

  private

  sig { void }
  def assist
    puts <<~INFO
      What info do you want to get?
        - 1-#{@pieces.size} to display a piece spot
        - `a` to display all
        - `q` to exit
    INFO

    while true
      print 'Choose: '
      res = $stdin.gets.strip.downcase
      case res
      when /^\d$/
        puts @pieces[res.to_i - 1]
      when 'a'
        puts @pieces.join("\t\t")
      when 'q'
        return
      end
    end
  end

  sig { params(cell: String).returns(Grid) }
  def add_cell(cell)
    col = cell.tr('0-9', '').tr('A-H', '1-8').to_i
    row = cell.tr('A-Z', '')
    if row =~ /(\d)-(\d)/
      (T.must(Regexp.last_match)[1].to_i..T.must(Regexp.last_match)[2].to_i).each do |row|
        @spots << [row, col]
      end
    else
      row.each_char do |c|
        @spots << [c.to_i, col]
      end
    end
    self
  end

  sig { params(piece: Piece).returns(Grid) }
  def add_piece(piece)
    @pieces << piece
    self
  end

  sig { params(piece: Piece, covered: T::Hash[[Integer, Integer], T::Boolean]).void }
  def mark_coverage(piece, covered)
    piece.covered_spots(self).each do |row, col|
      covered[[row, col]] = true
    end
  end

  sig { returns(T::Boolean) }
  def valid?
    @grid.clear
    covered = T.let(Hash.new(false), T::Hash[[Integer, Integer], T::Boolean])

    @opponents.each do |opp|
      @grid[[opp.row, opp.col]] = opp
    end
    @pieces.each do |piece|
      @grid[[piece.row, piece.col]] = piece
    end

    # disable taken pieces
    to_disable = {}
    @opponents.each do |opp|
      opp.covered_spots(self).each do |row, col|
        to_disable[@grid[[row, col]]] = true
      end
    end
    @pieces.each do |piece|
      next if to_disable[piece]

      mark_coverage(piece, covered)
    end

    @spots.all? do |row, col|
      covered[[row, col]]
    end
  end
end

grids = T.let([], T::Array[Grid])
grids << Grid.new('A39').add_pieces(Bishop, Rook, Rook, Queen)
             .add_cells(%w[B3 B4 B5 B7 C2 C3 C6 D2 D3 D4 D5 D6 D8 E1 E3 E4 E7 F4 F5 G2 G3 G4 G5 G7])
grids << Grid.new('A42').add_pieces(Pawn, Bishop, Bishop, Rook, Rook)
             .add_cells(%w[B2 B4 B6 B7 C2-7 D2-6 E4-5 F3 F5-7 G2-7])
grids << Grid.new('A45').add_pieces(Knight, Knight, Rook, Rook)
             .add_cells(%w[C4 C5 C6 D3 D4 D5 E4 E5 F3 F4 F5 F6 G3 G4])
grids << Grid.new('A48').add_pieces(Pawn, Knight, Queen, Queen)
             .add_cells(%w[A4-6 B3-6 C3-6 D3-6 E2 E4-6 F4-6 G2 G4-6 H3 H5-6])
grids << Grid.new('M1').add_pieces(Knight, Bishop, Rook, Queen)
             .add_opponent(Rook.new(row: 7, col: E))
             .add_cells(%w[B5-7 C5-7 D5-7 E2-4 F2-4 G2-4])
grids << Grid.new('M13')
             .add_pieces(Knight, Bishop, Rook, Queen)
             .add_cells(%w[B3 C1-7 D2-5 D7-8 E1 E3-5 E7-8 F3-4 F6-7 G3-5 G7 H5-6])
grids << Grid.new('M15').add_pieces(Knight, Bishop, Bishop, Rook, Rook)
             .add_cells(%w[B2 B5 B7 C2-3 C5-7 D2-3 D7 E3 F3 F5 F7 G2 G5 G7])
grids << Grid.new('M17').add_pieces(Pawn, Pawn, Knight, Knight, Bishop, Rook)
             .add_cells(%w[B3 B5 B7 C2 C4-6 D3 D7 E2 E4 E6 F5-7 G2 G5])
grids << Grid.new('M19').add_pieces(Knight, Bishop, Bishop, Rook, Rook)
             .add_opponent(Bishop.new(row: 7, col: C))
             .add_cells(%w[B2 B4-6 C2 C4-6 D2 D4-6 E2 E5 F2 F5 G2 G4-6])
grids << Grid.new('M20').add_pieces(Bishop, Rook, Queen)
             .add_opponent(Queen.new(row: 7, col: C))
             .add_cells(%w[B4 C3-5 D3-7 E3-5 F3-5 F7 G4])
grids << Grid.new('M22').add_pieces(Pawn, Pawn, Pawn, Knight, Rook, Rook)
             .add_opponent(Pawn.new(row: 6, col: G, opp: true))
             .add_cells(%w[C3-6 D3-6 E3-6 F3-6])
grids << Grid.new('M23').add_pieces(Pawn, Knight, Knight, Bishop, Rook)
grids << Grid.new('M25').add_pieces(Pawn, Knight, Knight, Rook, Rook)
             .add_cells(%w[B3 B5-6 C3-5 D2-3 D5-6 E2-3 E5-6 F3-6 G3 G5-6])
grids << Grid.new('M26').add_pieces(Pawn, Pawn, Bishop, Rook, Queen)
             .add_opponent(Knight.new(row: 8, col: G))
             .add_cells(%w[B5-7 D2-7 E2-7 G5-7])
grids << Grid.new('M27').add_pieces(Knight, Bishop, Queen, King)
             .add_cells(%w[B2 B4 C2-7 D2-5 E1-6 F3-6 G4-7 H6-8])
grids << Grid.new('M28').add_pieces(Pawn, Pawn, Knight, Rook, Rook)
             .add_cells(%w[B3-6 C4-6 D4-5 E3-5 F3-5 G4-5])
grids << Grid.new('M29').add_pieces(Pawn, Pawn, Knight, Bishop, Rook, Rook)
             .add_opponent(Rook.new(row: 6, col: D))
             .add_cells(%w[B2 B7 C3 C6 D4-5 E4-5 F3 F6 G2 G7])
grids << Grid.new('M30').add_pieces(Pawn, Knight, Bishop, Rook, Rook)
             .add_cells(%w[B2-4 C3-5 D3-6 E2 E4 E6-7 F2-3 F5-6])
grids << Grid.new('M31').add_pieces(Knight, Bishop, Rook, Queen)
             .add_cells(%w[A2-3 B2-4 C2-5 D1-7 E2-6 F2-7 G4 G6-7])
grids << Grid.new('M32').add_pieces(Pawn, Knight, Bishop, Rook, Rook)
             .add_cells(%w[A2 B2-3 C2-7 D3-7 E3-5 F2-4 F6 G2-5 H3])
grids << Grid.new('M33').add_pieces(Knight, Bishop, Rook, Queen)
             .add_opponent(Rook.new(row: 6, col: D))
             .add_cells(%w[B3 C2-5 D2-5 E3-6 F2-6 G2456])
grids << Grid.new('M35').add_pieces(Pawn, Bishop, Bishop, Rook, Rook)
             .add_cells(%w[A2368 B2378 C124 D58 E48 F24567 G58 H46])
grids << Grid.new('M36').add_pieces(Pawn, Knight, Bishop, Bishop, Rook)
             .add_opponent(Rook.new(row: 4, col: A))
             .add_cells(%w[A3 B357 C2-6 D2-6 E3-5 F236 G35])
grids << Grid.new('M37').add_pieces(Knight, Knight, Bishop, Bishop, Rook, Rook)
             .add_opponent(Rook.new(row: 8, col: D))
             .add_opponent(Rook.new(row: 8, col: E))
             .add_cells(%w[B2-7 D1-6 E2-7 G1-6])
grids << Grid.new('M38').add_pieces(Pawn, Bishop, Rook, Rook, Queen)
             .add_opponent(King.new(row: 4, col: E))
             .add_cells(%w[B6 C2-5 D2-6 E2356 F2-6 G2-6])
grids << Grid.new('M39').add_pieces(Knight, Bishop, Rook, King)
             .add_cells(%w[B2-6 C23567 D34 E2-6 F45 G356])
grids << Grid.new('M40').add_pieces(Knight, Bishop, Rook, Rook)
             .add_cells(%w[A1578 B23 C124567 D123457 E24 F14578 G2 H127])
grids << Grid.new('GM6').add_pieces(Bishop, Bishop, Rook, Queen)
             .add_opponent(Rook.new(row: 7, col: D))
             .add_opponent(Bishop.new(row: 5, col: E))
             .add_cells(%w[B2-3 B6-7 C2-3 C6-7 F2-3 F6-7 G2-3 G6-7])
grids << Grid.new('GM7').add_pieces(Knight, Bishop, Rook, Rook, Rook)
             .add_cells(%w[A24 B2457 C1-8 D1-7 E2468 F2457 G1-7 H237])
grids << Grid.new('GM12').add_pieces(Pawn, Knight, Knight, Rook, Queen)
             .add_opponent(Knight.new(row: 8, col: D))
             .add_cells(%w[C3-6 D36 E36 F3-6])

name = ARGV[0]
grid = grids.find { _1.name == name }
grid&.find_solution
