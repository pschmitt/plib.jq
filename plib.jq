module {
  "name": "plib",
  "description": "pschmitt's jq stdlib",
  "homepage": "https://github.com/pschmitt/plib.jq",
  "license": "GPL3",
  "author": "Philipp Schmitt",
  "repository": {
    "type": "git",
    "url": "https://github.com/pschmitt/plib.jq"
  }
};

def getallpaths(cols):
  . as $obj |
  reduce $cols[] as $col (
    {}; . + {
      ($col): $obj | getpath($col / ".")
    }
  );


# def strpaths:
#   # Below is shorter but does not support keys with dots correctly
#   # path(..) | [.[] | tostring] | join(".");
#   path(..) | map(
#     if type == "string" and contains(".") then
#       "[\"\(.|gsub("\""; "\\\""))\"]"
#     elif type == "string" then
#       ".\(.|gsub("\""; "\\\""))"
#     else
#       "[\(.)]"
#     end
#   ) | join("") | sub("^\\."; "");

# def strpaths(include_values):
#   path(..) as $p |
#   $p | map(
#     if type == "string" and contains(".") then
#       "[\"\(.|gsub("\""; "\\\""))\"]"
#     elif type == "string" then
#       ".\(.|gsub("\""; "\\\""))"
#     else
#       "[\(.)]"
#     end
#   ) | join("") | sub("^\\."; "") as $path |
#   if include_values == true then
#     $path + ":" + (getpath($p) | tostring)
#   else
#     $path
#   end;

def pathtostring:
  if type == "string" and contains(".")
  then
    "[\"\(.)\"]"
  elif type == "string"
  then
    ".\(.)"
  else # array
    "[\(.)]"
  end;

def strpathsWithoutValues:
  paths(scalars) | (map(pathtostring) | join(""));

def strpathsWithValues:
  paths(scalars) as $p |
  [
    ($p | map(pathtostring)| join("")),
    (getpath($p) | tojson)
  ] | join(" = ");

def strpaths(with_values):
  if with_values == true
  then
    strpathsWithValues
  else
    strpathsWithoutValues
  end;

def strpaths: strpaths(false);

def ellipsize(max_length; style):
  "…" as $ellipsis |
  . as $text |
  if ($text | length) > max_length then
    if style == "middle" then
      ((max_length - 3) / 2 | floor) as $half
      | $text[0:$half] + $ellipsis + $text[-$half:]
    else
      (max_length - 3) as $start
      | $text[0:$start] + $ellipsis
    end
  else
    $text
  end;

def ellipsize(max_length):
  ellipsize(max_length; "end");

def ellipsize:
  ellipsize(40; "end");
