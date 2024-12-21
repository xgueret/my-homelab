check_remote_file(){
    (( $(curl -sI $1 | grep -E "^HTTP" \
    | awk -F " " '{print $2}') == 200))
}

# yml_files=""

for cloudimg in $(yq '.templates[].name' roles/configure/vars/main/cloud_init_and_template.yml); do

    echo "---"
    echo "Updating checksum for $cloudimg"
    baseurl=$(dirname $(yq '.templates[] | select(.name == '$cloudimg') | .cloud_init_image.url' roles/configure/vars/main/cloud_init_and_template.yml) | tr -d '"')
    imgname=$(basename $(yq '.templates[] | select(.name == '$cloudimg') | .cloud_init_image.url' roles/configure/vars/main/cloud_init_and_template.yml) | tr -d '"')
    checksumtype=$(yq '.templates[] | select(.name == '$cloudimg') | .cloud_init_image.url_checksum' roles/configure/vars/main/cloud_init_and_template.yml | awk -F':' '{print $1}' | tr -d '"')
    checksumfile="${checksumtype^^}SUMS"
    # Si le fichier de checksum n'est pas trouvable sous la forme XXXXXXSUMS alors on cherche <imagename>.xxxxxx
    ! check_remote_file "$baseurl/$checksumfile" && echo "Checksum file not found : $baseurl/$checksumfile, trying $baseurl/$imgname.$checksumtype" && checksumfile="$imgname.$checksumtype" && imgname=""
    if check_remote_file "$baseurl/$checksumfile"; then
        echo "Using checksum from : $baseurl/$checksumfile"
        checksum=$(curl -sL "$baseurl/$checksumfile" | grep "$imgname" | awk '{print $1}')

#         yq -y '.templates[] | select(.name == '$cloudimg') | .cloud_init_image.url_checksum |= "'$checksumtype':'$che
# cksum'"' roles/configure/vars/main/cloud_init_and_template.yml > roles/configure/vars/main/cloud_init_and_template.$(echo $cloudimg | tr -d '"').yml

        yq -yi '(.templates[] | select(.name == '$cloudimg').cloud_init_image.url_checksum) |= "'$checksumtype':'$checksum'"' roles/configure/vars/main/cloud_init_and_template.yml
        [[ $? -eq 0 ]] && echo "Checksum for $cloudimg updated : $(yq '.templates[] | select(.name == '$cloudimg') | .cloud_init_image.url_checksum' roles/configure/vars/main/cloud_init_and_template.yml)"
        # yml_files="$yml_files roles/configure/vars/main/cloud_init_and_template.$(echo $cloudimg | tr -d '"').yml"
    else
        echo "No checksum file found"
    fi

done

# yq '.templates[] as $item ireduce ({}; . *+ $item)' $yml_files