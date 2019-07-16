Param(
    $solrVersion
)

$solrName = "solr-$solrVersion"

Write-Output 'Setting Security to TLS 1.2'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Output 'Prevent the progress meter from trying to access the console'
$global:progressPreference = 'SilentlyContinue'

$siteRoot = "D:\home\site\wwwroot"

Write-Output "Downloading Solr $solrVersion zip to D:\home\site"

$downloadSource = "https://archive.apache.org/dist/lucene/solr/$solrVersion/$solrName.zip"
Invoke-WebRequest -Uri $downloadSource -UseBasicParsing -OutFile "..\solr.zip"

Write-Output "Expanding Solr zip at D:\home\site directory as D:\home\site\$solrName"
Expand-Archive "..\solr.zip" -DestinationPath "..\"

Write-Output "Copying contents of D:\home\site\$solrName to D:\home\site\wwwroot"

xcopy "..\$solrName\*" "..\wwwroot" /S /Y

Write-Output 'Copy web.config from repository to D:\home\site\wwwroot'
xcopy web.config ..\wwwroot /Y