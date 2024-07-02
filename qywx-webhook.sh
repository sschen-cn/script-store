#!/bin/bash
# jenkins构建发送企业微信群bot消息
# filter out strings
search_strings=("Merge" "合并" "mod")
# send message info to wxwork
commit_info=""
# git commit info
git_log=$(git log ${GIT_PREVIOUS_SUCCESSFUL_COMMIT}..${GIT_COMMIT} --pretty=format:"> %cn: %s :%ci")
#git_log=$(git log 227393c6..99825fbc --pretty=format:"- %cn: %s :%ci")
# wxwork webhook key
webhook_key="76280e19-1cd0-4877-885f-xxxxxxxxxxxx"
while IFS= read -r line; do
    matched=false
    for search_string in ${search_strings[@]}; do
        if [[ $line == *$search_string* ]]; then
            matched=true
            break
        fi
    done
    if ! $matched; then
        trimmed_line=${line::-6}
        commit_info+="\n$trimmed_line"
    fi
done <<<"$git_log"
if [ -n "$commit_info" ]; then
  echo $commit_info
    curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key="'$key'"' -H 'Content-Type: application/json' -d '
        {
            "msgtype": "markdown",
            "markdown": {
                "content": "'"$JOB_NAME"' 已发布 \n发布内容： \n '"$commit_info"' \n",
            }
        }'
fi
