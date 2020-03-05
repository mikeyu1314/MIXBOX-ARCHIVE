wgetsh() {
	# 传入下载的文件位置和下载地址，自动下载到${mbtmp}，若成功则移到下载位置
	[ -z "$1" -o -z "$2" ] && return 1
	[ -x /opt/bin/curl ] && alias curl=/opt/bin/curl
	local wgetfilepath="$1"
	local wgetfilename=$(basename $wgetfilepath)
	local wgetfiledir=$(dirname $wgetfilepath)
	local wgeturl="$2"
	[ ! -d "$wgetfiledir" ] && mkdir -p $wgetfiledir
	[ ! -d ${mbtmp} ] && mkdir -p ${mbtmp}
	rm -rf ${mbtmp}/${wgetfilename}
	if command -v wget-ssl &> /dev/null; then
		result1=$(wget-ssl --no-check-certificate --tries=1 --timeout=10 --spider -nv -O "${mbtmp}/${wgetfilename}" "$wgeturl")
	else
		result1=$(curl -skL --connect-timeout 10 -m 20 -w %{http_code} -o "${mbtmp}/${wgetfilename}" "$wgeturl")
	fi
	[ -f "${mbtmp}/${wgetfilename}" ] && result2=$(du -sh "${mbtmp}/${wgetfilename}" 2> /dev/null | awk '{print$1}')
	if echo -n "$result1" | grep -q "200" && [ "$result2" != '0' ]; then
		chmod +x ${mbtmp}/${wgetfilename} > /dev/null 2>&1
		mv -f ${mbtmp}/${wgetfilename} $wgetfilepath > /dev/null 2>&1
		return 0
	else
		rm -rf ${mbtmp}/${wgetfilename}
		return 1
	fi

}

wgetlist() {
	[ -z "$1" ] && echo -n ""
	if command -v wget-ssl &> /dev/null; then
		wget --no-check-certificate -q -O - "$1"
	else
		curl -kfsSl "$1"
}

base_encode() {
	if [ -z "${1}" ]; then
		echo -n "" 
	else
		if command -v base64_encode &> /dev/null; then
			echo -n "$*" | base64_encode
		else
			echo -n "$*" | baseutil --b64
		fi
	fi
}

base_decode() {
	if [ -z "${1}" ]; then
		echo -n "" 
	else
		if command -v base64_decode &> /dev/null; then
			echo -n "$*" | base64_decode
		else
			echo -n "$*" | baseutil --b64 -d
		fi
	fi
}