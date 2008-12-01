#!/bin/bash
#
# bashcms
# Author: Shapor Naghibzadeh
#
# generates tabified html pages from content stubs and template files

tmp=/tmp/$0.$$
tablist=.templates/order
header=.templates/header.html
footer=.templates/footer.html
middle=.templates/middle.html
title=$(cat .templates/title 2>/dev/null || echo bashcms)

if [[ $1 == "clean" ]]; then
	echo "cleaning up generated files..."
	for name in */.index.html; do
		echo rm ${name/\/*/}.html
		rm ${name/\/*/}.html || true
	done 2>/dev/null
	exit
fi

function fname {
	local -r name=$1
	cat $name/.name 2>/dev/null || echo $name
}

declare -a tabs order
echo "reading tab list from '$tablist'"
read -a order <$tablist || exit

j=0
for i in $(seq 0 $(( ${#order[@]} - 1 ))); do
	if [[ ! -d ${order[$i]} ]]; then
		echo "directory '${order[$i]}' not found, skipping..."
		continue
	fi
	tabs[$j]=${order[$i]}
	names[$j]=$(fname ${tabs[$j]})
	let j++
done

for i in $(seq 0 $(( ${#tabs[@]} - 1 ))); do
	tab=${tabs[$i]}
	name=${names[$i]}

	pushd $tab >/dev/null|| exit
	<../$header sed "s/<title><\/title>/<title>$title - $name<\/title>/" >$tmp

	for j in $(seq 0 $(( ${#tabs[@]} - 1 ))); do
		if [[ $i -eq $j ]]; then
			echo "		<li><span>$name</span>"
			# FIXME TODO: add subtab support here
			# <ul id="secondary">
			# 	<li><a href="philosophy.html">Our Philosophy</a></li>
			#	<li><span>Our Processes</span></li>
			# 	<li><a href="employment.html">Employment Opportunities</a></li>
			# </ul>
		else
			echo "		<li><a href='${tabs[$j]}.html'>${names[$j]}</a></li>"
		fi
	done >>$tmp

	cat ../$middle .index.html ../$footer >>$tmp
	mv $tmp ../$tab.html
	popd >/dev/null
done
