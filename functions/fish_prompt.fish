set ARROW_RIGHT ""
set ARROW_RIGHT_SEP ""
set GIT_BRANCH_ICON ""
set RANGER_ICON ""
set THREE_DOTS "…"

set CWD_PATH_SEP " $ARROW_RIGHT_SEP "

set PROMPT_CWD_MAX_START 2
set PROMPT_CWD_MAX_END 2


function prompt_user
	set -gx prompt_user_color $fish_color_user

	set -l user_str " $USER"
	set -l host_str ""
    if set -q SSH_TTY; and set -q fish_color_host_remote
		set prompt_user_color $fish_color_user_remote 
		set host_str "@$hostname "
	end

	if functions -q fish_is_root_user; and fish_is_root_user
		set user_str "$user_str "
		set prompt_user_color -b red black
	end

    echo -n -s (set_color -o $prompt_user_color) $user_str (set_color normal) \
		(set_color $prompt_user_color) $host_str " " (set_color normal)
end

function prompt_cwd
	set -q argv[1]
	or set argv $PWD

	set -l path (string escape --style=script $argv[1])
	set -l realhome (string escape --style=regex -- ~)

	set path (string replace -r "^$realhome" '~' $path)

	set -q prompt_cwd_max_start
	or set -l prompt_cwd_max_start $PROMPT_CWD_MAX_START

	set -q prompt_cwd_max_end
	or set -l prompt_cwd_max_end $PROMPT_CWD_MAX_END

	set -l m1 $prompt_cwd_max_start
	set -l m2 $prompt_cwd_max_end

	# escaped 'slash' (/) character 
	set -l SLASH '\/'

	# At start of line (^) match 0 or 1 (?) forward slash, 0 or more (*) non forward
	# slashes [^/] and 0 or 1 (?) forward slash -> at least once and at most $m1 times
	# {1,$m1}
	set -l regex_part1 "^($SLASH?[^/]*$SLASH?){1,$m1}"

	# At end of line ($) match 0 or 1 (?) forward slash at least one (+)
	# non-forward slash [^/] and 0 or 1 (?) forward slash ->
	# at least once and at most $m2 times {1, $m2}
	set -l regex_part2 "($SLASH?[^/]+$SLASH?){1,$m2}\$"

	# group all repeating forward slashes and replace them with a single
	# forward slash
	set path (string replace -ra "$SLASH+" "$SLASH" $path)

	set -l part1 (string match -r $regex_part1 $path)[1]
	set path (string replace -ra $regex_part1 '' $path)

	set -l part2 (string match -r $regex_part2 $path)[1]
	set path (string replace -ra $regex_part2 '' $path)

	# If path is not empty then we need to shorten it, to display
	# that it has been shortened we place a character showing three
	# dots between part1 and part2 of the path
	if [ -n "$path" ]
		set path "$part1$THREE_DOTS$part2"
	else
		set path "$part1$part2"
	end

	# Get last element, this element will be made bold to give
	# a highlighting effect.
	# We do it in this order because there may only be one element
	# so we need to prevent duplicate elements.

	# SYNTAX NOTE FOR FUTURE ME: the '^' character inside the '[' and ']'
	# characters means NOT, so [^/] means match any character that's not a '/'.
	# But outside '[]' it means start of line so ^/ means match a '/'
	# character at the start of a line.
	# '*' means match 0 or more, '$' means end of line, '+' means 1 or more
	# and '|' means OR/alternatively.

	# Match at least one non '/' character and 0 or more '/' characters
	# at end of line
	set -l last_elem_regex "[^/]+$SLASH*\$"

	# Match 0 or more '/' characters and at least one non '/' character
	# at start of line alternatively match 1 or more '/' characters at start of line
	# (for when we navigate to / (root) display '/')
	set -l first_elem_regex "^$SLASH*[^/]+|^$SLASH+"
	set -l last_elem (string match -r $last_elem_regex $path)[1]

	# remove last element
	set path (string replace -r $last_elem_regex '' $path)

	# get first element
	set -l first_elem (string match -r $first_elem_regex $path)
	# and remove
	set path (string replace -r $first_elem_regex '' $path)

	# Replace the remaining slashes with our own fancy path separator
	set path (string replace -ra "$SLASH+" "$CWD_PATH_SEP" $path)

	# make the last element bold
	set -l bold_elem $last_elem

	set -l cwd_remain $path

	echo -sn (set_color $cwd_color) ' ' $first_elem \
		$cwd_remain \
		(set_color -o $cwd_color) $bold_elem ' ' (set_color normal)
end

function fish_prompt --description 'Write out the prompt'
    set -l last_pipestatus $pipestatus
	set -l last_status $status
    #set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
    set -l normal (set_color normal)
    set -q fish_color_status
	or set -g fish_color_status red

	# Color the prompt differently when we're root
	set -l color_cwd $fish_color_cwd
	#set -l suffix "$normal$(set_color 666; echo -n $ARROW_RIGHT; set_color normal)"
	if functions -q fish_is_root_user; and fish_is_root_user
		if set -q fish_color_cwd_root
			set color_cwd $fish_color_cwd_root
		end
		#set suffix '#'
	end

	set -l last_bg normal
	set -lx fish_color_user -b white black
	set -lx fish_color_user_remote -b yellow black
	set -lx cwd_color -b 54445e white
	set -l suffix "$normal$(set_color -b normal $cwd_color[2]; echo -n $ARROW_RIGHT; set_color normal)"

	set -l prompt_user_str (prompt_user)

	set last_bg $prompt_user_color[2]
	set -e prompt_user_color


	set prompt_user_str "$prompt_user_str$(set_color -b $cwd_color[2] $last_bg)$ARROW_RIGHT"

	set -l prompt_cwd_str (prompt_cwd)
	set last_bg $cwd_color[2]

	
    echo -n -s $prompt_user_str $prompt_cwd_str $normal $suffix " "
end
