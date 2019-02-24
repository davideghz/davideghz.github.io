###
# Page options, layouts, aliases and proxies
###

set :haml, { :format => :html5 }

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

activate :syntax, :line_numbers => true, :inline_theme => Rouge::Themes::Github.new

# Per-page layouts changes:
#
# With no layouts
page '/*.xml', layouts: false
page '/*.json', layouts: false
page '/*.txt', layouts: false

# With alternative layouts
# page "/path/to/file.html", layouts: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

###
# Helpers
###

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  blog.prefix = "posts"

  # blog.permalink = "{year}/{month}/{day}/{title}.html"
  blog.permalink = "{title}.html"
  blog.sources = "{year}-{month}-{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"

  blog.layout = "layouts/post"
  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 4
  blog.page_link = "page/{num}"
end

activate :directory_indexes

page "/feed.xml", layouts: false
# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

# Build-specific configuration
configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :relative_assets
end

