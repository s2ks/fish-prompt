set ARROW_LEFT "" 
set ARROW_LEFT_SEP ""  
set GIT_BRANCH_ICON ""

set normal (set_color normal)

function __prompt_exitstatus
    set -lx __fish_last_status $argv[1] # export for __fish_print_pipestatus.
	set -l last_pipestatus $argv[2..]

	# unsure what this does, or if it even works. $status_generation
	# seems to be a counter that increments after each command

	# **original comment**
	# write pipestatus
	# if the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
	set -l bold_flag --bold
	set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
	if test $__fish_prompt_status_generation = $status_generation
        set bold_flag
    end
    set __fish_prompt_status_generation $status_generation

    set -l status_color (set_color -b red black)
    set -l statusb_color (set_color $bold_flag black)

	set -l prompt_status (__fish_print_pipestatus "$normal$(set_color red)$ARROW_LEFT$(set_color -b red white) " \
		" " 					\
		" $ARROW_LEFT_SEP " 	\
		"$status_color" 		\
		"$statusb_color" 		\
		$last_pipestatus)

	echo -n -s $prompt_status
end

function fish_right_prompt --description 'Write out the right prompt'
    set -l last_pipestatus $pipestatus
	set -l last_status $status

	set -lx ___fish_git_prompt_color (set_color -o -b green black)
	set -lx ___fish_git_prompt_color_done (set_color normal)

    set -l status_prompt_str "$(__prompt_exitstatus $last_status $last_pipestatus)"
	set -l vcs_prompt_str "$(fish_vcs_prompt " %s ")"

	set -l prev_bg normal

	if [ -n $status_prompt_str ]
		set prev_bg red
	end

	if [ -n $vcs_prompt_str ]
		set vcs_prompt_str "$(set_color -b $prev_bg green)$ARROW_LEFT$vcs_prompt_str$(set_color -b green black)$GIT_BRANCH_ICON $normal"
		set prev_bg green
	end

	echo -n -s $status_prompt_str $normal $vcs_prompt_str 
end
