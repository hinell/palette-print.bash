#!/usr/bin/bash
# Title			: Palette Printer Bash
# Summary		: This script prints color palette (see preview). It works by
# using ASCI escape codes for background color.
# Created-at	: Monday, October 18, 2021 
# Repository	: N/A
# Authors		: Alex A. Davronov <al.neodim@gmail.com> (2021-)
# Description	: See README.MD
# Usage			: $ palette.bash | less -SRq


__palette.bash.name(){ echo -n "Palette Printer Bash"; }
__palette.bash.version(){ echo -n "v.1.0.0"; }
__palette.bash.last.modified(){ echo -n "Mon, October 18, 2021"; }
__palette.bash.license.notice(){
	cat <<-EOL
	Copyright (C) 2021- Alex A. Davronov <al.neodim@gmail.com>
	See LICENSE file or comment at the top of the main file
	provided along with the source code for additional info
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
	EOL
}

__palette.bash(){
	# -------------------------------------------------------------------palette.rgb
	# @summary I'm tasked with printing colored text in 256 colors (RGB)
	# @usage  $ palette.rgb 255 0 0 "X"
	# @param $r - Red    color
	# @param $g - Green  color
	# @param $b - Blue   color
	# @param $t - Blue   color
	palette.rgb()
	{
		
		local   r=${1:? $'\n'"$0: palette.rgb: R color is missing"};
		local   g=${2:? $'\n'"$0: palette.rgb: G color is missing"};
		local   b=${3:? $'\n'"$0: palette.rgb: B color is missing"};
		local   t=${4:? $'\n'"$0: palette.rgb: Text is missing"};
		local CLEAR="\e[0;m";
		local COLOR_BG="\e[;48;2;";
		echo -e "$CLEAR${COLOR_BG}${r};${g};${b}m${t}${CLEAR}"
	} # palette.rgb end 


	# -------------------------------------------------------------palette.rgb.to.10
	# @summary I'm tasked with printing decimal to hex
	# @usage  $ palette.rgb.to.16 255 255 255 => 0xffffff
	# @param $r - hexadecimal number
	# @param $g - hexadecimal number
	# @param $b - hexadecimal number
	palette.rgb.to.10() { printf '%03i %03i %03i' $1 $2 $3; }

	# -------------------------------------------------------------palette.rgb.to.16
	# @summary I'm tasked with printing decimal to hex
	# @usage  $ palette.rgb.to.16 255 255 255 => 0xffffff
	# @param $r - decimal number
	# @param $g - decimal number
	# @param $b - decimal number
	palette.rgb.to.16() { printf '0x%02x%02x%02x' $1 $2 $3; }

	# -----------------------------------------------------------palette.color.print
	# @summary I'm tasked with ... printing colored information
	# @usage $ palette.rgbs range {0..7} 255 {0..31} 0
	# @param $ l_range - Brightness range
	# @param $ r_range - Red color range
	# @param $ g_range - Green color range
	# @param $ b_range - Blue color range
	# @param $ format  - 10 for decimal, 16 for hex
	palette.color.print()
	{
		local    l_range=(${1:?"Brightness range is requried! e.g. {0..7}"});
		local -i l_range_length=${#l_range[@]};

		local    r_range=(${2});
		local    g_range=(${3});
		local    b_range=(${4});

		local    format=${5:-16};
		
		# Check if there are enough arguments
		#-------------------------------------
		local ERROR_MISSING_SECOND_ARG="${COLOR_FG}255;64;32mMore than 3 arguments are expected!$CLEAR"

		[[ ${#r_range[@]} -eq 0 ]] &&\
		[[ ${#g_range[@]} -eq 0 ]] &&\
		{
			echo $ERROR_MISSING_SECOND_ARG;
			return 1;
		};

		[[ ${#g_range[@]} -eq 0 ]] &&\
		[[ ${#b_range[@]} -eq 0 ]] &&\
		{
			echo $ERROR_MISSING_SECOND_ARG;
			return 1;
		};
		
		[[ ${#r_range[@]} -eq 0 ]] &&\
		[[ ${#b_range[@]} -eq 0 ]] &&\
		{
			echo $ERROR_MISSING_SECOND_ARG;
			return 1;
		};

		
		# Only ranges starting from 0 are allowed
		#-------------------------------------

		local -i b=1;
		
		# If no range for color is specified then
		# the quotient per each color is set to 1
		# (Color is fixed number)
		#-------------------------------------
		local -i r_range_qtn=1
		local -i g_range_qtn=1
		local -i b_range_qtn=1

		# If the range for color is specified,
		# then on each iteration we have to use a 
		# quotient to produce a final color
		#-------------------------------------    
		[[ ${#r_range[@]} -gt 1 ]] && r_range_qtn=$((256/${#r_range[@]}));
		[[ ${#g_range[@]} -gt 1 ]] && g_range_qtn=$((256/${#g_range[@]}));
		[[ ${#b_range[@]} -gt 1 ]] && b_range_qtn=$((256/${#b_range[@]}));


		# Intial colors
		local -i r=1;
		local -i g=1;

		local -i r_cmplmnt; local -i r_brgQuotient;
		local -i g_cmplmnt; local -i g_brgQuotient;
		local -i b_cmplmnt; local -i b_brgQuotient;

		# The palette string
		local    palette="";
		# These loops below are printing color from top to down
		for ir in "${r_range[@]}"; do
			# Color is fixed per row
			# Brightness - is not
			# palette+='\n'
			for ig in "${g_range[@]}"; do
				# palette+='\n'
				for ib in "${b_range[@]}"; do

					# The loop below is printing color from left to right
					# NOTE: this causes palette to have color "boundaries"
					# which are visible if range of color ends on 63
					r=$((ir*r_range_qtn));
					g=$((ig*g_range_qtn));
					b=$((ib*b_range_qtn));
					
					# Complementary of the colors
					r_cmplmnt=$((255-r));
					g_cmplmnt=$((255-g));
					b_cmplmnt=$((255-b));
					
					r_brgQuotient=$((r_cmplmnt/l_range_length));
					g_brgQuotient=$((g_cmplmnt/l_range_length));
					b_brgQuotient=$((b_cmplmnt/l_range_length));
									
					# Store coes in a separate column
					local colorlegend=" ";
					for Brightness_ in "${l_range[@]}"; do

						# Calculate fraction of the Brightness range supplied by user 
						sr=$((r+(Brightness_*r_brgQuotient)));
						sg=$((g+(Brightness_*g_brgQuotient)));
						sb=$((b+(Brightness_*b_brgQuotient)));
						
						palette+="`palette.rgb $sr $sg $sb "⣿"`";
						colorlegend+="$(palette.rgb.to.$format $sr $sg $sb) "
					done
					# Join color line & color codes lines
					palette+="$colorlegend\n";
				done
			done
			
		done;
		echo -en "$palette$CLEAR"
	} # palette.color.print end

	palette.cache.path(){ echo -n "/tmp/palette.bash.$1_$2_$3.cache.txt"; }
	# -----------------------------------------------------------------palette.print
	# @summary I'm tasked with printing a color palette and its hex codes
	# into the stdout
	# @usage  $ palette.print 15 15
	# @param $satMax - Brightness range; default to 7 (8 sub colors)
	# @param $rgbMax - Number of colors; default to 3 (3 colors total)
	# @param $format - Output format (radix); 16|10; default to 16 (hex)
	palette.print()
	{
		local satMax=${1:-7};
		local rgbMax=${2:-3};
		local format=${3:-16}
		
		# Map of the colors of the palette
		# r=16    g=0..16 b=0       - red
		# r=16..0 g=16    b=0

		# r=0     g=16    b=0..16   - green
		# r=0     g=16..0 b=16
		# r=0     g=0     b=16

		# r=0..16 g=0     b=16      - blue
		# r=16    g=0     b=16..0
		# r=16..0 g=0     b=0

		declare RNGA=$(eval "echo {0..$rgbMax}"); # Averse
		declare RNGB=$(eval "echo {$rgbMax..0}"); # Reverse
		declare STRN=$(eval "echo {0..$satMax}"); # Brightness

		declare output="";

		
		# Simple caching mechanism. All files are saved to /tmp
		#-------------------------------------
		declare cache_path="$(palette.cache.path $satMax $rgbMax $format)";
		if [[ -f "$cache_path" ]];
		then
			output=$(cat "$cache_path");
		else
			output+="$(palette.color.print "$STRN"   255       "$RNGA"    0        $format)\n"
			output+="$(palette.color.print "$STRN"  "$RNGB"    255        0        $format)\n"
			output+="$(palette.color.print "$STRN"   0         255        "$RNGA"  $format)\n"
			output+="$(palette.color.print "$STRN"   0         "$RNGB"    255      $format)\n"
			output+="$(palette.color.print "$STRN"   0         0         "$RNGB"   $format)"

			echo -e "$output" > "$cache_path"
		fi
		
		echo -en "$output";
	} # palette.print end


	# -------------------------------------------------------------------palette.cli
	# @summary I'm main function
	# @param $@	- Rest of arguments
	palette.cli()
	{
		local COMMAND=$1;
		case $COMMAND in
		#	(pattern);& # <- if match execute next commands
			(cache)
				rm -v $(palette.cache.path '*' '*' '*');
				echo "cache cleaned";
			;;
			(-h|--help|h|help)
				cat <<-EOL
				Use command examples insted!

				$(__palette.bash.name) $(__palette.bash.version) $(__palette.bash.last.modified)
				
				$(__palette.bash.license.notice)
				EOL
			;;
			(-v|--version|v|version) __palette.bash.version;;
			(x|examples)
			cat <<-EOL
			$(__palette.bash.name)
			
			BASIC USAGE:
			  $ ${0:-pallete.print}
			  $ ${0:-pallete.print} 7 3 10 # to get decimal RGB codes
			
			EOL
			
			;;
			(*) palette.print $@;;
		esac
	} # palette.cli end

	palette.cli $@

} # __palette.bash end

# ------------------------------------------------------------------__shell.name
# @summary I detect which kind shell (zsh, bashh etc..) the script is run in.
# @usage $ declare currentShell="$(__shell.name)";
# @param $shellName - A reference name for an output
__shell.name(){
    type compdef  &> /dev/null && { echo "zsh" ;  return 0; };
    type complete &> /dev/null && { echo "bash" ; return 0; };
}
# ---------------------------------------------------------main-function-export

if [[ ${BASH_SOURCE[0]} != $0 ]]; then
    # Alias the exported function, if necessary
    EXPORT_NAME="palette.bash"
    eval "$EXPORT_NAME(){ __palette.bash "\$@";}" &> /dev/null
    case "$(__shell.name)" in
        (zsh)
            # Exports for ZSH - FUCK ZSH
            eval "typeset -f $EXPORT_NAME" &> /dev/null
        ;;
        (bash);& 
        (*)
            # Exports for Bash and the rest
            eval "export -f $EXPORT_NAME"
        ;;
    esac
else
    __palette.bash "$@"
fi
