#!/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby

# Usage: redcarpet [<file>...]
# Convert one or more Markdown files to HTML and write to standard output. With
# no <file> or when <file> is '-', read Markdown source text from standard input.
if ARGV.include?('--help')
  File.read(__FILE__).split("\n").grep(/^# /).each do |line|
    puts line[2..-1]
  end
  exit 0
end

require 'rubygems'

begin
  require 'redcarpet'
  require 'pygments'
rescue LoadError
  puts <<-HTML
  <style>
  .error h2 {color: red;}
  .error .hint h3 {color: #555;}
  </style>

  <div class="error">
  <h2>Please install the following gems on your system Ruby</h2>

  <pre><code>
  unset GEM_HOME
  unset GEM_PATH

  sudo /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/gem install redcarpet -v 2.3.0
  sudo /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/gem install pygments.rb
  </code></pre>

  </div>
  HTML
  exit 0
end

css = "<style>#{Pygments.css(:style => "colorful")}</style>"

class HTMLwithPygments < Redcarpet::Render::HTML
  def block_code(code, language)
    language ||= 'text'
    Pygments.highlight(code, :lexer => language)
  rescue
    Pygments.highlight(code, :lexer => 'text')
  end
end

def markdown(text)
  renderer = HTMLwithPygments.new(:hard_wrap => false, :filter_html => false)
  options = {
    :autolink            => true,
    :space_after_headers => true,
    :fenced_code_blocks  => true,
    :tables              => true,
    :strikethrough       => true,
    :smart               => true,
    :hard_wrap           => false, # true,
    :safelink            => true,
    :no_intraemphasis    => true,
  }
  Redcarpet::Markdown.new(renderer, options).render(text)
end


puts [css, markdown(ARGF.read)].join

