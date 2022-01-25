#! /usr/bin/env ruby

def help
  puts <<~USAGE
    Usage: password_gen.rb [size] [--hex|--anum] [--lower|--upper]

    Generates a random password.
    Default charset is ASCII printable chars (32 - 126) with the exception of:
    ' ', '/', '\\', '@', '"', "'"

    Options:
      size       Number of characters, defaults to 24

      Charset:
        --hex    Use hexadecimal charset    (lower case)
        --anum   Use alphanumerical charset (lower and upper case)

      Casing:
        --lower  Use only lowercase letters
        --upper  Use only uppercase letters
  USAGE
end

if ARGV.delete('--help') || ARGV.delete('-h')
  help
  exit 0
end

charset = (32..126).map(&:chr) - [' ', '/', '\\', '@', '"', "'"]

if ARGV.delete('--hex')
  charset = %w(0 1 2 3 4 5 6 7 8 9 a b c d e f)
elsif ARGV.delete('--anum')
  charset = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
end

if ARGV.delete('--lower')
  charset = charset.map(&:downcase).uniq
elsif ARGV.delete('--upper')
  charset = charset.map(&:upcase).uniq
end

count = 24

if ARGV.size == 1 && (ARGV[0] =~ /^\d+$/)
  count = ARGV[0].to_i
elsif ARGV.size > 0
  help
  exit 1
end

puts count.times.map { charset.sample }.join('')
exit 0
