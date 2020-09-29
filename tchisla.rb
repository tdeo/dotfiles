#! /usr/bin/env ruby

require 'set'

details = ARGV.delete('--details')
target, k = ARGV[0..1].map(&:to_i)

def facto(a)
  (2..a).reduce(1, :*)
end

def square?(a)
  return false if a <= 1
  r = Math.sqrt(a).round
  r.finite? && a == r * r
end

def sqrt(a)
  Math.sqrt(a).round
end

class Tchisla
  def initialize(target, c, k)
    @target = target
    @values = [k] * c
    @c = c
    @viewed = Set.new()
  end

  def solve(values = @values.dup, concatenation: true, depth: 15,backtrack: [])
    return backtrack if values.include?(@target)
    return nil if depth < 0
    return nil if @viewed.include?(values.sort)
    @viewed << values.sort
    (0...values.size).each do |i|
      (0...values.size).each do |j|
        vals = values.dup
        a = vals.delete_at([i, j].max)
        r = nil
        if i != j
          b = vals.delete_at([i, j].min)
          r ||= solve(vals.dup + [a + b], concatenation: false, depth: depth, backtrack: backtrack.dup + ["#{a + b} = #{a} + #{b}"])
          r ||= solve(vals.dup + [a * b], concatenation: false, depth: depth, backtrack: backtrack.dup + ["#{a * b} = #{a} * #{b}"])
          r ||= solve(vals.dup + [a - b], concatenation: false, depth: depth, backtrack: backtrack.dup + ["#{a - b} = #{a} - #{b}"])
          r ||= solve(vals.dup + [b - a], concatenation: false, depth: depth, backtrack: backtrack.dup + ["#{b - a} = #{b} - #{a}"])
          r ||= solve(vals.dup + [a ** b], concatenation: false, depth: depth, backtrack: backtrack.dup + ["#{a ** b} = #{a}^#{b}"]) if a > 1 && b.abs < 50 && (a**b) < 10 ** 30
          r ||= solve(vals.dup + [b ** a], concatenation: false, depth: depth, backtrack: backtrack.dup + ["#{b ** a} = #{b}^#{a}"]) if b > 1 && a.abs < 50 && (b**a) < 10 ** 30
          r ||= solve(vals.dup + [a / b], concatenation: false, depth: depth, backtrack: backtrack.dup + ["#{a / b} = #{a} / #{b}"]) if b != 0 && a % b == 0
          r ||= solve(vals.dup + [b / a], concatenation: false, depth: depth, backtrack: backtrack.dup + ["#{b / a} = #{b} / #{a}"]) if a != 0 && b % a == 0
          r ||= solve(vals.dup + [(a.to_s + b.to_s).to_i], concatenation: true, depth: depth) if concatenation
        end
        r ||= solve(vals.dup + [facto(a)], concatenation: false, depth: depth - 1, backtrack: backtrack.dup + ["#{facto(a)} = #{a}!"]) if a < 10 && a > 2
        r ||= solve(vals.dup + [sqrt(a)], concatenation: false, depth: depth - 1, backtrack: backtrack.dup + ["#{sqrt(a)} = V(#{a})"]) if square?(a)
        return r unless r.nil?
      end
    end
    nil
  rescue
  end
end

c = 1
sol = nil
while sol.nil?
  break if c > 10
  solver = Tchisla.new(target, c, k)
  sol = solver.solve
  unless sol.nil?
    puts "#{target} with #{c} #{k}'s:"
    break unless details
    sol.each do |op|
      puts "\t" + op
    end
    break
  end
  c += 1
end
