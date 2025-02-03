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

# re-order keys followint the order of a provided array
# usage:
# $ DATA=$(gh pr list --repo NixOS/nixpkgs --json url,state,number,title)
# $ jq -er --argjson cols '["title","state","url"]' \
#   'map(p::reorder_keys($cols))' <<< "$DATA"
def reorder_keys(cols):
  . as $og

  # keys our og object actually has
  | ($og | keys_unsorted) as $actual_keys
  # leftover = any keys that are not in $cols
  | ($actual_keys - cols) as $leftovers
  # final order = desired keys first, then leftovers
  | (cols + $leftovers) as $all_keys
  # Build a new object with the keys in the desired order
  | reduce $all_keys[] as $k (
      {};
      . + (
        if $og | has($k)
        then
          { ($k): $og[$k] }
        else
          {}
        end
      )
    );

# OSC 8 escape sequence (hyperlinks)
# usage: p::osc8("click me"; "https://example.com")
def osc8(text; url):
  # ESC ] 8 ;; <url> BEL <text> ESC ] 8 ;; BEL
  "\u001B]8;;"
  + url
  + "\u0007"
  + text
  + "\u001B]8;;"
  + "\u0007";

def age(ts):
  (now - (ts | fromdate)) as $seconds_diff
  | if $seconds_diff < 0 then "N/A"
    else
      if $seconds_diff < 60 then
        "\($seconds_diff | floor)s"
      elif $seconds_diff < 3600 then
        "\(($seconds_diff / 60 | floor))m"
      elif $seconds_diff < 86400 then
        "\(($seconds_diff / 3600 | floor))h"
      else
        (($seconds_diff / 86400 | floor)) as $days
        | if $days >= 365 then
            (($days / 365) | floor) as $years
            | ($days % 365) as $remaining_days
            | (if $remaining_days > 0 then "\($years)y\($remaining_days)d" else "\($years)y" end)
          else
            "\($days)d"
          end
      end
    end;
