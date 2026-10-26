-- Adds two things to posts in notes/<post>/ and journal/<post>/:
--   1. `reading-time` metadata (shown next to the date by _partials/title-metadata.html)
--   2. "previous / next" links at the end, ordered by date, skipping drafts.
-- Other pages (home, about, listing pages) are left untouched.

local SECTIONS = { notes = true, journal = true }
local WORDS_PER_MINUTE = 230
local SOURCE_EXTS = { "qmd", "md", "ipynb" }

local function relpath(path)
  local root = quarto.project.directory .. "/"
  return path:sub(1, #root) == root and path:sub(#root + 1) or path
end

-- Returns section, post-folder if the document is a post, else nil.
local function post_location()
  local rel = relpath(pandoc.path.directory(quarto.doc.input_file))
  return rel:match("^(%a+)/([^/]+)$")
end

local function find_source(dir)
  for _, ext in ipairs(SOURCE_EXTS) do
    local path = pandoc.path.join({ dir, "index." .. ext })
    local f = io.open(path, "r")
    if f then
      local content = f:read("a")
      f:close()
      return path, ext, content
    end
  end
end

local function read_post(section_dir, name)
  local path, ext, content = find_source(pandoc.path.join({ section_dir, name }))
  if not path then return nil end
  local ok, doc = pcall(pandoc.read, content, ext == "ipynb" and "ipynb" or "markdown")
  if not ok then return nil end
  local m = doc.meta
  return {
    name = name,
    file = "index." .. ext,
    title = m.title and pandoc.utils.stringify(m.title) or name,
    date = m.date and pandoc.utils.stringify(m.date) or name,
    draft = m.draft == true or (m.draft and pandoc.utils.stringify(m.draft) == "true"),
  }
end

local function nav_link(post, label, class)
  return pandoc.Div({
    pandoc.Plain({
      pandoc.Link({
        pandoc.Span(label, { class = "post-nav-label" }),
        pandoc.Str(post.title),
      }, "../" .. post.name .. "/" .. post.file),
    }),
  }, { class = class })
end

local function post_nav(section, current)
  local section_dir = pandoc.path.join({ quarto.project.directory, section })
  local posts = {}
  for _, name in ipairs(pandoc.system.list_directory(section_dir)) do
    local post = read_post(section_dir, name)
    if post and (name == current or not post.draft) then
      table.insert(posts, post)
    end
  end
  table.sort(posts, function(a, b)
    if a.date ~= b.date then return a.date < b.date end
    return a.name < b.name
  end)

  local older, newer
  for i, post in ipairs(posts) do
    if post.name == current then
      older, newer = posts[i - 1], posts[i + 1]
    end
  end
  if not older and not newer then return nil end

  local children = {}
  if older then table.insert(children, nav_link(older, "← Previous", "post-nav-prev")) end
  if newer then table.insert(children, nav_link(newer, "Next →", "post-nav-next")) end
  return pandoc.Div(children, { class = "post-nav" })
end

local function reading_time(blocks)
  local words = 0
  pandoc.Blocks(blocks):walk({
    Str = function() words = words + 1 end,
    CodeBlock = function(cb)
      -- Code is read slower than prose, but it still counts.
      words = words + select(2, cb.text:gsub("%S+", ""))
    end,
  })
  local minutes = math.max(1, math.floor(words / WORDS_PER_MINUTE + 0.5))
  return minutes .. " min"
end

function Pandoc(doc)
  if not quarto.doc.is_format("html") then return nil end
  local section, name = post_location()
  if not section or not SECTIONS[section] then return nil end

  doc.meta["reading-time"] = reading_time(doc.blocks)
  local nav = post_nav(section, name)
  if nav then doc.blocks:insert(nav) end
  return doc
end
