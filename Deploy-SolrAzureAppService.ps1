Param(
    $solrVersion
)

$solrName = "solr-$solrVersion"

Write-Output 'Copy wwwroot folder'
xcopy wwwroot ..\wwwroot /Y

Write-Output 'Setting Security to TLS 1.2'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Output 'Prevent the progress meter from trying to access the console'
$global:progressPreference = 'SilentlyContinue'

Write-Output 'Downloading Solr $solrVersion'
$downloadSource = "https://archive.apache.org/dist/lucene/solr/$solrVersion/$solrName.zip"
Start-BitsTransfer -Source $downloadSource -Destination \wwwroot\solr.zip
Expand-Archive \wwwroot\solr.zip -DestinationPath \wwwroot\$solrName
