#!/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin/ruby

# Usage: redcarpet [<file>...]
# Convert one or more GitHub Flavour Markdown files to HTML and write to
# standard output. With no <file> or when <file> is '-', read Markdown source
# text from standard input.
if ARGV.include?('--help')
  File.read(__FILE__).split("\n").grep(/^# /).each do |line|
    puts line[2..-1]
  end
  exit 0
end

require 'rubygems'

begin
  require 'html/pipeline'
  require 'linguist'
  require 'github/markdown'
  require 'sanitize'
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

  sudo /System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin/gem install html-pipeline github-markdown github-linguist sanitize
  
  </code></pre>

  </div>
  HTML
  exit 0
end

context = {
  :gfm       => false,
}

filters = [
  HTML::Pipeline::MarkdownFilter,
  HTML::Pipeline::SanitizationFilter,
  HTML::Pipeline::SyntaxHighlightFilter,
]

pipeline = HTML::Pipeline.new filters, context
puts pipeline.call(ARGF.read)[:output].to_s
